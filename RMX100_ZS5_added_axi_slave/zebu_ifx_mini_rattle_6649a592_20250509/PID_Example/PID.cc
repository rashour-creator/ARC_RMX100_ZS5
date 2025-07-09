#include <iostream>
/* defining the rdtime() macro */
#define rdtime()     ({unsigned long __tmp; \ 
__asm__ volatile ("csrr     %0, mcycle" \ 
: "=r" (__tmp) /*output : register */ \      
: /*input : none */ \         
:/*clobbers:none */); \
__tmp; })

class PIDController {
private:
    double Kp, Ki, Kd;
    double setpoint;
    double int_term;
    double derivative_term;
    double last_error;

public:
    PIDController(double Kp = 1.0, double Ki = 0.0, double Kd = 0.0, double set_point = 0)
        : Kp(Kp), Ki(Ki), Kd(Kd), setpoint(set_point), int_term(0), derivative_term(0), last_error(0) {}

    void set_set_point(double set) {
        setpoint = set;
    }

    double get_control(double measurement, double dt) {
        double error = setpoint - measurement;
        int_term += error * Ki * dt;
        if (last_error != 0) {
            derivative_term = (error - last_error) / dt * Kd;
        }
        last_error = error;
        return Kp * error + int_term + derivative_term;
    }
};

int main() {
unsigned long t1 = rdtime();
    unsigned long t2 = rdtime();
    unsigned long overhead = t2 - t1;
std::cout << "rdtime() overhead: " << overhead << " cycles" << std::endl;
unsigned long Begin_Time,End_Time,Elapsed_Time;
    double measurement = 0.0;
    double dt = 0.1;

    std::cout << "Simulating PID control to reach setpoint 10.0\n";
    Begin_Time = rdtime();
    PIDController pid(2.0, 0.5, 0.1, 10.0); // Kp=2, Ki=0.5, Kd=0.1, setpoint=10
    double control = pid.get_control(measurement, dt);
    End_Time = rdtime();
    std::cout << "Control=" << control << ", Measurement=" << measurement << std::endl;
    std::cout << "The Begin Time is: " << Begin_Time <<std::endl;
    std::cout << "The End Time is: " << End_Time <<std::endl;
Elapsed_Time = End_Time - Begin_Time -2*overhead;
std::cout << "The Elapsed Time is: " << Elapsed_Time <<std::endl;
    return 0;
}

