#!/bin/env python3

import sys
import os
import argparse
import re
import subprocess
import signal

class ProcessZebuDump():

  # Global variables
  script_path = os.path.abspath(os.path.dirname(__file__))
  this_host   = os.uname()[1]

  def __init__(self):
    self.w_dir = ""
    self.args = self.get_parser()
    if self.args['no_grid'] == False:
        if 'SUBMITCMDSH' in os.environ:
            self.grid_cmd = os.environ['SUBMITCMDSH']
        else:
            print (">>> Disabling grid since SUBMITCMDSH not defined")
            self.args['no_grid'] = True
    signal.signal(signal.SIGTERM, self.sigterm_handler)

  def run(self):
    try:
      self.i_host, self.i_path = self.get_remote_host()
      self.w_dir = self.create_workspace()
      self.prepare_remote_input_file()
      self.i_dir, self.i_name, self.i_ext = self.parse_input_file()
      self.o_dir = self.check_out_dir()
      self.arch_build = self.get_arch_build()
      self.syn_freq = self.get_syn_freq()
      self.paths = self.populate_paths()
      print (">>> Using following (intermediate) file paths:")
      for k in self.paths: print(">>>   " + k + ' : ' + self.paths[k])
      self.move_to_workspace()
      if 'ztdb' in self.paths and 'saif' in self.paths: self.ztdb_to_saif()
      if 'fsdb' in self.paths and 'saif' in self.paths: self.fsdb_to_saif()
      if 'saif' in self.paths and 'rpt'  in self.paths: self.saif_to_rpt()
      if 'rpt'  in self.paths and 'csv'  in self.paths: self.rpt_to_csv()
      if 'ztdb' in self.paths and 'fsdb' in self.paths: self.ztdb_to_fsdb()
      if 'fsdb' in self.paths and 'peak' in self.paths: self.fsdb_to_peak()
      if 'ztdb' in self.paths and 'wsh'  in self.paths: self.ztdb_to_wsh()
      if self.args['g']:
        if   'fsdb' in self.paths: self.open_fsdb()
        elif 'ztdb' in self.paths: self.open_ztdb()
      self.exit(0)

    except KeyboardInterrupt: # if applition is killed
      self.exit("User interrupt")

  def get_parser(self):

    parser = argparse.ArgumentParser(
                        description='Transform ZeBu dump into multiple output formats',
                        formatter_class=lambda prog: argparse.HelpFormatter(prog,max_help_position=45,width=160))

    parser.add_argument('-i', '--input', dest = 'i',
                        help = 'path to input file (ztdb, fsdb or saif)',
                        required = True)
    parser.add_argument('-f', '--format', dest = 'f',
                        help = 'list of desired output formats',
                        choices = ['ztdb', 'saif', 'fsdb', 'rpt', 'peak', 'csv', 'wsh'],
                        nargs = '+', default = [], required = True)
    parser.add_argument('-o', '--output_dir', dest = 'o',
                        help = 'path to place outputs (default: same as folder as input)',
                        required = False)
    parser.add_argument('-w', '--work_dir', dest = 'w',
                        help = 'temporary work space dir (default: same as current for local input files, /remote for remote ones)',
                        required = False)
    parser.add_argument('-z', '--arch_build_path', dest = 'z',
                        help = 'path of ARChitect build/ containing ZeBu zCui.work (default: current directory)',
                        default = os.environ['PWD'], required = False)
    parser.add_argument('-g', '--gui', dest = 'g',
                        help = 'open output file in GUI mode when possible (FSDB)',
                        action = 'store_true', default = False, required = False)
    parser.add_argument('--syn_freq',
                        help = 'synthesys frequency in MHz of the ZeBu model (default: value in build_configuration.txt)',
                        type = int, required = False)
    parser.add_argument('--tech_corner',
                        help = 'operation conditions for power analysis (default: typical corner [tt])',
                        choices = ['tt', 'ff', 'ss'], default = 'tt', required = False)
    parser.add_argument('--no_grid',
                        help = 'do not use SGE grid even when possible',
                        action = 'store_true', default = False, required = False)
    parser.add_argument('--no_cleanup',
                        help = 'do not remove work space and (unnecessary) big intermediate results (ZTDB and SAIF)',
                        action = 'store_true', default = False, required = False)
    parser.add_argument('-n', '--dry_run', dest = 'n',
                        help = 'only print commands, not execute them',
                        action = 'store_true', default = False, required = False)

    return vars(parser.parse_args())

  def is_in_sge(self, path):
    return (self.run_cmd("readlink -f {}".format(path))[0] == 0) and \
           (self.run_cmd("readlink -f {} | grep -qE '^\/SCRATCH'".format(path))[0] != 0)

  def get_remote_host(self):
    i_arg  = self.args['i'].strip().rstrip('/').split(':')
    if len(i_arg) == 1 or self.is_in_sge(i_arg[1]) or i_arg[0] == self.this_host:
      i_host = "local"
      i_path = i_arg[-1]
    else:
      i_host = i_arg[0]
      i_path = i_arg[1]
    return i_host, i_path

  def create_workspace(self):
    if self.args['w'] != None:
      w_dsk = os.path.abspath(self.args['w'])
    else:
      w_dsk = os.path.realpath(os.environ['PWD'])
    status, w_dir = self.run_cmd("mktemp -d --tmpdir={} process_zebu_dump.work_XXXXXX".format(w_dsk))
    if status != 0: self.exit(">>> Failed creating work directory")
    return w_dir

  def prepare_remote_input_file(self):
    if self.i_host != "local":
      print(">>> Remote input file found in {}, moving to directory accesible by current machine {}".format(self.i_host, self.this_host))
      status, out = self.run_cmd("time ssh {} cp -r {} {}".format(self.i_host, self.i_path, self.w_dir), verbose = True, live=True, show_only = self.args['n'])
      if status != 0:
        self.exit(">>> Failed moving {}:{} to {}:{}. Check file exist and there is space".format(self.i_host, self.i_path, self.this_host, self.w_dir))
      elif not self.args['no_cleanup']:
        self.run_cmd("ssh {} rm -rf {}".format(self.i_host, self.i_path), show_only = self.args['n'])
      self.i_path = self.w_dir+'/'+os.path.split(self.i_path)[1] # Update input file path
      if self.args['n'] == True: self.run_cmd("touch " + self.i_path) # Create dummy file for empty run

  def move_to_workspace(self):
    os.chdir(self.w_dir)
    print(">>> Moving to work directory {}:{}".format(self.this_host, self.w_dir))

  def exit(self, ret):
    if not self.args['no_cleanup'] and self.w_dir != "":
      print(">>> Removing temp work dir: " + self.w_dir)
      self.run_cmd("rm -rf " + self.w_dir)
    sys.exit(ret)

  def sigterm_handler(_signo, _stack_frame):
    sys.exit("Kill signal captured")

  def parse_input_file(self):
    if not os.path.exists(self.i_path):
      self.exit(">>> Input file {} does not exist (or it is remote and the host was not specified)".format(self.i_path))
    else:
      i_dir, i_file = os.path.split(os.path.abspath(self.i_path))
      self.i_path = os.path.abspath(self.i_path)
      print(">>> Reading input file: " + self.i_path)
      matches = re.findall('ztdb|fsdb|saif|rpt', i_file)
      if len(matches) > 0:
        i_ext  = matches[-1]
        i_name = i_file.split('.'+i_ext)[0]
        print(">>> Input file format: " + i_ext)
      else:
        self.exit(">>> Unknown/unsupported input file")
    return i_dir, i_name, i_ext

  def check_out_dir(self):
    o_dir = self.i_dir
    if self.args['o']:
      o_dir = os.path.abspath(self.args['o'])
    if not os.path.exists(o_dir):
      os.makedirs(o_dir)
    print(">>> Output directory set to: " + o_dir)
    return o_dir

  def get_arch_build(self):
    arch_build = self.args['z']
    if os.path.exists(arch_build + "/zcui.work/"):
      arch_build = os.path.abspath(arch_build)
      print(">>> Using ARChitect build path: " + arch_build)
    else:
      self.exit(">>> Could not find valid ARChitect build")
    return arch_build

  def get_syn_freq(self):
    if self.args['syn_freq'] != None:
      syn_freq = self.args['syn_freq']
    else:
      status, syn_freq = self.run_cmd("grep '\-clock_speed' {}/build_configuration.txt | cut -d' ' -f2".format(self.arch_build))
      if status != 0: self.exit(">>> Could not determine synthesis frequency")
    print(">>> Emulation frequency: {} MHz".format(syn_freq))
    return syn_freq

  def populate_paths(self):
    paths = {}
    ordered_paths = [ ['ztdb', 'saif', 'rpt', 'csv' ],
                      ['ztdb', 'fsdb', 'peak'       ],
                      ['fsdb', 'saif', 'rpt', 'csv' ],
                      ['ztdb', 'wsh'                ]]

    desired_formats = self.args['f']
    required_formats = []
    for path in [p for p in ordered_paths if self.i_ext in p]: # get paths containing our input format
      start_idx = path.index(self.i_ext)
      for f in [d for d in desired_formats if d in path]:      # get paths containing our desired output format (TODO: do this check in the first loop)
        end_idx = path.index(f)
        for i in range(start_idx, end_idx+1):                  # get all necessary intermediate formats in the path
          required_formats.append(path[i])
      required_formats = list(set(required_formats))
    for f in required_formats:                                 # compute location of all files
      if   f == self.i_ext:      paths[f] = self.i_path
      elif f in desired_formats: paths[f] = self.o_dir + '/' + self.i_name + '.' + f + (".gz" if f == 'saif' else "")
      else:                      paths[f] = self.w_dir + '/' + self.i_name + '.' + f + (".gz" if f == 'saif' else "")
    for f in desired_formats:
      if not f in required_formats: self.exit(">>> Impossible to get {} from {}".format(f, self.i_ext))
    return paths

  def run_cmd(self, cmd, live = False, verbose = False, show_only = False):
    if verbose: print(">>> Executing: " + cmd)
    if show_only: return 0, ''
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, encoding='UTF-8')
    if live:
      while True:
        out = p.stdout.read(1)
        if out == '' and p.poll() != None:
            break
        if out != '':
            sys.stdout.write(out)
            sys.stdout.flush()
    else: p.wait()
    out = p.stdout.read().strip()
    return p.returncode, out

  def ztdb_to_saif(self):
    # TODO: if ZTDB can not be processed in parallel (`grep START_CYCLE <ztdb>/main | wc` == 1), do it faster in ZeBu host
    in_sge  = self.is_in_sge(self.paths['ztdb']) and self.is_in_sge(self.paths['saif'])
    fw_saif = "-forwardsaif" if os.path.isfile(self.arch_build+"/saif/fw_ram.saif") else ""
    cmd = 'time swave -work {}/zcui.work/ -i {} -saif {} -fullsaifdump {} -flatten_genhier -selfcheck -stats 2 -timescale {:.3f}ns -aligntimescale -pthreads 6 {}'.format(
          self.arch_build, self.paths['ztdb'], self.paths['saif'], fw_saif, 1e3/int(self.syn_freq),
          '-grid "{}" -gridmaxjobs 50'.format(self.grid_cmd) if not self.args['no_grid'] and in_sge else '')
    status, out = self.run_cmd(cmd, live = True, verbose = True, show_only = self.args['n'])
    if status != 0:
      # TODO: if failed because of grid, can be retried with "-redo"
      self.args['no_cleanup'] = True # Do not delete ZTDB if failure here
      self.exit(">>> Failed generating SAIF. Check swave.log")
    elif not 'ztdb' in self.args['f'] and not self.args['no_cleanup']:
      self.run_cmd("rm -rf " + self.paths['ztdb'], show_only = self.args['n'])
      print(">>> SAIF dump sucessful, removing ZTDB: " + self.paths['ztdb'])
    self.run_cmd("sed -i '' " + self.paths['saif']) # Funny trick to replace symblink to file in tmp_dir to actual file

  def fsdb_to_saif(self):
    in_sge = self.is_in_sge(self.paths['fsdb']) and self.is_in_sge(self.paths['saif'])
    cmd = 'time swave -work {}/zcui.work/ -i {} -saif {} -fullsaifdump -flatten_genhier -selfcheck -stats 2 -aligntimescale -pthreads 6 {}'.format(
          self.arch_build, self.paths['fsdb'], self.paths['saif'],
          '-grid "{}"'.format(self.grid_cmd) if not self.args['no_grid'] and in_sge else '')
    status, out = self.run_cmd(cmd, live = True, verbose = True, show_only = self.args['n'])
    if status != 0:
      self.exit(">>> Failed generating SAIF. Check swave.log")
    elif not 'fsdb' in self.args['f'] and not self.args['no_cleanup']:
      self.run_cmd("rm -rf " + self.paths['fsdb'], show_only = self.args['n'])
      print(">>> SAIF dump sucessful, removing FSDB: " + self.paths['fsdb'])
    self.run_cmd("sed -i '' " + self.paths['saif']) # Funny trick to replace symblink to file in tmp_dir to actual file

  def saif_to_rpt(self):
    in_sge = self.is_in_sge(self.paths['saif']) and self.is_in_sge(self.paths['rpt'])
    rpt_dir = "{}/pt_reports".format(os.path.split(self.paths['rpt'])[0])
    if self.args['tech_corner'] != "tt": rpt_dir += "_"+self.args['tech_corner']
    self.run_cmd("mkdir -p {}".format(rpt_dir))
    cmd = "time pt_shell -file {}/../zebu_power/power.tcl -x 'set SRC_DIR {{{}}}; set CORNER {{{}}}; set SAIF_FILE {{{}}}; set LOG_PATH {{{}}}' | tee {}/power_analysis.log".format(
          self.script_path, self.arch_build, self.args['tech_corner'], self.paths['saif'], rpt_dir, rpt_dir) # TODO: Should we use the grid here too?
    status, out = self.run_cmd(cmd, live = True, verbose = True, show_only = self.args['n'])
    if status != 0:
      self.exit(">>> Failed generating PT average power reports")
    elif not 'saif' in self.args['f'] and not self.args['no_cleanup']:
      self.run_cmd("rm -rf " + self.paths['saif'], show_only = self.args['n'])
      print(">>> PrimeTime average power report sucessful, removing SAIF: " + self.paths['saif'])
    self.run_cmd("cp {}/power_hierarchy.rpt {}".format(rpt_dir, self.paths['rpt']))
    if 'rpt' in self.args['f']:
      self.run_cmd("cp {}/parasitics_command.log {}/spef_check.rpt".format(self.w_dir, rpt_dir))

  def rpt_to_csv(self):
    cmd = "time {}/../zebu_power/extract_hier_power_summary.py -i {} -m {}/../zebu_power/ev.report.map -f {}".format(
          self.script_path, self.paths['rpt'], self.script_path, self.syn_freq)
    status, out = self.run_cmd(cmd, live = True, verbose = True, show_only = self.args['n'])
    if status != 0:
      self.exit(">>> Failed generating CSV report")
    self.run_cmd("mv {} {}".format(os.path.splitext(self.paths['rpt'])[0]+'.summary.csv', self.paths['csv']))

  def ztdb_to_fsdb(self):
    in_sge = self.is_in_sge(self.paths['ztdb']) and self.is_in_sge(self.paths['fsdb'])
    # For large ZTDB, dump to zwd by changing --fsdb into --zwd in below command, its x5 faster
    cmd = 'time zSimzilla -z {build}/zcui.work/zebu.work/ --ztdb {ztdb} --fsdb {fsdb} -t {scale:.4f}ns -j 99 --threads {thrd} {grid}'.format(
          build= self.arch_build, ztdb = self.paths['ztdb'], fsdb = self.paths['fsdb'],
          scale= 1e3/int(self.syn_freq), thrd = 32 if self.args['no_grid'] else 6,
          grid = ' -c "{}"'.format(self.grid_cmd) if not self.args['no_grid'] and in_sge else '')
    status, out = self.run_cmd(cmd, live = True, verbose = True, show_only = self.args['n'])
    if status != 0:
      self.exit(">>> Failed generating FSDB/ZWD")
    elif not 'ztdb' in self.args['f'] and not self.args['no_cleanup']:
      self.run_cmd("rm -rf " + self.paths['ztdb'], show_only = self.args['n'])
      print(">>> FSDB/ZWD dump sucessful, removing ZTDB: " + self.paths['ztdb'])

  def open_ztdb(self):
      cmd = 'verdi -emulation --input {} --zebu-work {}/zcui.work/zebu.work --timescale {:.3f}ns'.format(
            self.paths['ztdb'], self.arch_build, 1e3/int(self.syn_freq))
      self.run_cmd(cmd, verbose = True, show_only = self.args['n'])

  def open_fsdb(self):
      cmd = 'verdi -ssf {}.vf -dbdir {}/zcui.work/vcs_splitter/simv.daidir/'.format(self.paths['fsdb'], self.arch_build)
      self.run_cmd(cmd, verbose = True, show_only = self.args['n'])

  def fsdb_to_peak(self):
    in_sge = self.is_in_sge(self.paths['fsdb']) and self.is_in_sge(self.paths['peak'])
    peak_dir = os.path.split(self.paths['peak'])[0]
    self.run_cmd("mkdir -p {}/pt_peak_reports".format(peak_dir))
    cmd = "time pt_shell -file {}/../zebu_power/power_peak.tcl -x 'set SRC_DIR {{{}}}; set CORNER {{tt}}; set FSDB_FILE {{{}.vf}}; set LOG_PATH {{{}/pt_peak_reports}}'  | tee {}/power_peak_analysis.log".format(
          self.script_path, self.arch_build, self.paths['fsdb'], peak_dir, peak_dir) # TODO: Should we use the grid here too?
    status, out = self.run_cmd(cmd, live = True, verbose = True, show_only = self.args['n'])
    if status != 0:
      self.exit(">>> Failed generating PT power waves")
    elif not 'fsdb' in self.args['f'] and not self.args['no_cleanup']:
      self.run_cmd("rm -rf " + self.paths['fsdb'], show_only = self.args['n'])
      print(">>> PrimeTime power waves sucessful, removing FSDB: " + self.paths['fsdb'])
    #if self.args['g']:
      ## FIXME: result stored as <peak_dir>/pt_reports/power_top_waveform.fsdb, not self.paths['peak'] (which is also wrong)
      #cmd = 'verdi -nologo -ssf {}/pt_reports/power_top_waveform.fsdb -emulation --zebu-work {}/zcui.work/zebu.work'.format(peak_dir, self.arch_build)
      #self.run_cmd(cmd, verbose = True, show_only = self.args['n'])

  def ztdb_to_wsh(self):
    in_sge = self.is_in_sge(self.paths['ztdb']) and self.is_in_sge(self.paths['wsh'])
    rpt_dir = "{}/wsh_reports".format(os.path.split(self.paths['wsh'])[0])
    if self.args['tech_corner'] != "tt": rpt_dir += "_"+self.args['tech_corner']
    self.run_cmd("mkdir -p {}".format(rpt_dir))
    cmd = "time wsh -file {}/../zebu_power/empower.tcl -x 'set SRC_DIR {{{}}}; set CORNER {{{}}}; set ZTDB_FILE {{{}}}; set ZTDB_FREQ {{{}}}; set LOG_PATH {{{}}}' | tee {}/power_analysis.log".format(
          self.script_path, self.arch_build, self.args['tech_corner'], self.paths['ztdb'], self.syn_freq, rpt_dir, rpt_dir) # TODO: Should we use the grid here too?
    status, out = self.run_cmd(cmd, live = True, verbose = True, show_only = self.args['n'])
    if status != 0:
      self.exit(">>> Failed generating Wattson average power reports")
    elif not 'ztdb' in self.args['f'] and not self.args['no_cleanup']:
      self.run_cmd("rm -rf " + self.paths['ztdb'], show_only = self.args['n'])
      print(">>> Wattson average power report sucessful, removing ZTDB: " + self.paths['ztdb'])
    self.run_cmd("cp {}/power_hierarchy.rpt {}".format(rpt_dir, self.paths['wsh']))
    self.run_cmd("cp {}/wsh_work/archipelago.stim1.annotation.rpt {}/ztdb_not_annotated.rpt".format(self.w_dir, rpt_dir))

if __name__ == "__main__":
  try:
    ProcessZebuDump().run()
  except SystemExit as e:
    if str(e) != '0': print(e)
    os._exit(str(e) != '0')

