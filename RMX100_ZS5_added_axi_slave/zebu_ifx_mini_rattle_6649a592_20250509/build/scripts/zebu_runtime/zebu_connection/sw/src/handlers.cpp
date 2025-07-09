#include "handlers.h"

AddressHandler* AddressHandler::m_addressHandler = nullptr;
uint8 data = 0;
// Filling the map with handlers for each address
AddressHandler::AddressHandler()
{
	#if AXI_XTOR_TCP_IP == 1
	fillReadAddressHandlers();
	fillWriteAddressHandlers();
	#endif
}

// Returning the single handler instance
AddressHandler* AddressHandler::getHandlerInstance()
{
	if(!m_addressHandler)
		m_addressHandler = new AddressHandler();

	return m_addressHandler;
}

#if AXI_XTOR_TCP_IP == 1
void AddressHandler::fillReadAddressHandlers()
{
	m_readAddressHandlers[AXI_ACC_CLIENT_RECV_DATA_FLAG] = &AddressHandler::handleAxiAcceptClientRecvDataFlag;
	m_readAddressHandlers[AXI_INPUT_DATA_READY_FLAG] = &AddressHandler::handleAxiInputDataReadyFlag;
	m_readAddressHandlers[AXI_INPUT_BASE_ADDR] = &AddressHandler::handleAxiImageAddress;
	m_readAddressHandlers[AXI_INPUT_BASE_ADDR + MAX_INPUT_SZ] = &AddressHandler::handleAxiReadDefaultAddress;
	m_readAddressHandlers[AXI_TERMINATE_APP_FLAG] = &AddressHandler::handleAxiTerminateApp;
}

void AddressHandler::fillWriteAddressHandlers()
{
	
	m_writeAddressHandlers[AXI_OUTPUT_BASE_ADDR] = &AddressHandler::handleAxiDetectionsAddress;
	m_writeAddressHandlers[AXI_SEND_OUTPUT_ADDR_FLAG] = &AddressHandler::handleAxiSendOutputAddressFlag;
	m_writeAddressHandlers[AXI_OUTPUT_BASE_ADDR + DETECTIONS_SZ] =  &AddressHandler::handleAxiWriteDefaultAddress;
}
#endif // AXI_XTOR_TCP_IP

void AddressHandler::handleReadCallback()
{
	#if AXI_XTOR_TCP_IP == 1 
		ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t currentAddress;

		// Image address space
		if (m_readAddress >= AXI_INPUT_BASE_ADDR && m_readAddress < AXI_INPUT_BASE_ADDR + MAX_INPUT_SZ)
		{
			// std::cout << "Inside if" << std::endl;
			currentAddress = AXI_INPUT_BASE_ADDR;
		}

		// Default address space	
		else if (m_readAddress >= AXI_INPUT_BASE_ADDR + MAX_INPUT_SZ || m_readAddress == AXI_SEND_OUTPUT_ADDR_FLAG)
		{
			currentAddress =  AXI_INPUT_BASE_ADDR + MAX_INPUT_SZ;
		}
		// Handled address space
		else
		{
			currentAddress = m_readAddress;
		}

		// Calling address handlers
		(this->*m_readAddressHandlers[currentAddress])();

	#elif AXI_XTOR_DEFAULT == 1
		handleAxiReadDefaultAddress();
	#endif
	// Sending back the m_response to the master (ARC)
	// std::cout << "We are about to send to to the ARC" << std::endl;
	bool respId = g_objAmbaSlave->sendReadResponse();

		// Error in sending m_response to the ARC
	if(!respId)
	{
		std::cout << "Error while sending back the respose" << std::endl;
		exit(EXIT_FAILURE);
	}
	
}

void AddressHandler::handleWriteCallback()
{
	#if AXI_XTOR_TCP_IP == 1
		ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t currentAddress;
		// if (m_writeAddress >= AXI_OUTPUT_BASE_ADDR && m_writeAddress <= AXI_MEMORY_SZ_BYTES)
		// {
		// 	currentAddress = AXI_OUTPUT_BASE_ADDR;
		// }

	//Detections address space
		if (m_writeAddress >= AXI_OUTPUT_BASE_ADDR && m_writeAddress < (AXI_OUTPUT_BASE_ADDR + DETECTIONS_SZ))
		{
			currentAddress = AXI_OUTPUT_BASE_ADDR;
		}
		// Indicating detections are already set and ready to be sent when app on ARC writes in this flag.
		else if (m_writeAddress == AXI_SEND_OUTPUT_ADDR_FLAG)
		{
			currentAddress = AXI_SEND_OUTPUT_ADDR_FLAG;
		}
		//Default address space
		else 
		{
			currentAddress = AXI_OUTPUT_BASE_ADDR + DETECTIONS_SZ;
		}

		//calls the corresponding handler for the current address being accessed.
		(this->*m_writeAddressHandlers[currentAddress])();
	
	#elif AXI_XTOR_DEFAULT == 1
		handleAxiWriteDefaultAddress();
	#endif


	// Sending back the m_response to the master (ARC)
	bool resp = g_objAmbaSlave->sendWriteResponse();

	// Error sending back the g_currentResponse
	if(!resp)
	{
		std::cout << "Error sending back the g_currentResponse" << std::endl;
		exit(EXIT_FAILURE);
	}

}

void AddressHandler::setReadAddress(ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t ra)
{
	m_readAddress = ra;
}

void AddressHandler::setWriteAddress(ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t wa)
{
	m_writeAddress = wa;
}

void AddressHandler::setResponse(ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIResp * r)
{   //printf("handler is in m_response \n");
	//if(m_response !=nullptr){
		//printf("handler is deleting the old m_response \n");
		//printf("m_response = %p\n",m_response);
		//delete m_response;
		
	//}
		
	m_response = r;
	//printf("handler set new m_response \n");
}

void AddressHandler::setReadData(ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIData * rd)
{
	if(m_readData != nullptr)
		//delete m_readData;

	m_readData = rd;
}

void AddressHandler::setWriteData(uint8 * wd)
{
	m_writeData = wd;
}

void AddressHandler::setBurstLength(int bl)
{
	m_burstLength = bl;
}

void AddressHandler::setSize(int s)
{
	m_size = s;
}
void AddressHandler::setTotalBytes(int sz, int bl)
{
	m_totalBytes = (m_burstLength + 1) * (1 << m_size);
}

void AddressHandler::setPtrToImageBuffer(char * ptr)
{
	m_ptrToImageBuffer = ptr;
}

void AddressHandler::handleAxiWriteDefaultAddress()
{
	int totalBytes = 0;

	totalBytes = writeInMemory();

	g_objAmbaSlave->storeWriteResponse(m_response);
}


void AddressHandler::handleAxiReadDefaultAddress()
{
	auto it = m_slaveMemory.find(m_readAddress);

	if(it == m_slaveMemory.end())
	{
		m_slaveMemory[m_readAddress] = 0;
	}

	setReadDataResponse(nullptr, false);
}


#if AXI_XTOR_TCP_IP == 1
// Opening a thread for accepting a new client and getting data from it using a TCP/IP socket
void AddressHandler::handleAxiAcceptClientRecvDataFlag()
{
	// // Will be solved later
	// static uint8 data = 0;

	// Accepting a client and receiving data from it
	if(!g_flags.socketThreadStarted)
	{
		// std::cout << "inside detach" << std::endl;
		g_socketThread = std::thread(startServer);
		g_socketThread.detach();
		g_flags.socketThreadStarted = true;
	}

	// Return 0 if no client was connected to the server, 1 otherwise
	if (!g_flags.clientAccepted)
	{       std::cout << "There in no client connected" << std::endl;
		data = 0;
		setReadDataResponse(&data, true);
	}
	else 
	{       std::cout << "There is client connected" << std::endl;
		data = 1;
		setReadDataResponse(&data, true);
	}
}

void AddressHandler::handleAxiInputDataReadyFlag()
{
	// // Will be solved later
	// static uint8 data = 0;
	
	if (!g_flags.dataReceived)
	{  std::cout << "There is no input data ready to process" << std::endl;
		data = 0;
		setReadDataResponse(&data, true);
	}
	else 
	{   std::cout << "There is input data ready to process" << std::endl;
		data = 1;
		setReadDataResponse(&data, true);
		// set the dataRecevied flag in the handler of the send output
		// g_flags.dataReceived = false;
	}
}


void AddressHandler::handleAxiImageAddress()
{
	// Getting the correct offset for the image
	int offset = (m_readAddress - AXI_INPUT_BASE_ADDR);

	// Filling the returned data with specific 8 bytes
	// if (m_totalBytes == 8)
	// {
	// 	m_readData->FillWord64(*((uint64*)(m_ptrToImageBuffer + offset)));
	// }
	// else
	// {
	// 	for (ushort i=0; i<m_totalBytes; ++i)
	// 	{
			
	// 	}
	// }
	m_readData->FillByteArray((const uint8_t*)(m_ptrToImageBuffer + offset), m_totalBytes);
	//std::cout << "The AXI_INPUT_BASE_ADDR in the APIs is" << AXI_INPUT_BASE_ADDR << std::endl;
    //for (int i=0; i<8; ++i)
	//{   
		//printf("Byte %d: 0x%02X\n", i, static_cast<uint8_t>(m_ptrToImageBuffer[i]));
		
	//}
	// Making the returned responses valid
	ZEBU_IP::XTOR_AMBA_DEFINES_SVS::enAXIResp rresp = ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXI_RESP_OKAY;
	m_response->AddResp(rresp);

	// Storing the m_response and the data inside the software queue (to be returned to the master)
	g_objAmbaSlave->storeReadResponse(m_response, m_readData);
}



void AddressHandler::handleAxiDetectionsAddress()
{
	// std::cout << "Inside the detection handler" << std::endl;

	int totalBytes = 0;

	totalBytes = writeInMemory();
	std::cout << "The total number of bytes written is " <<totalBytes <<std::endl;

std::cout << "Memory contents at write address:\n";
for (int i = 0; i < m_totalBytes; ++i) {
signed char val = static_cast<signed char>(m_slaveMemory[m_writeAddress + i]);
std::cout << "Byte " << i << ": " << static_cast<int>(val)
<< " (0x" << std::hex << static_cast<int>(static_cast<unsigned char>(val)) << std::dec << ")\n";
}

// Copy memory into a local buffer
char outputBuffer[4];
//memcpy(outputBuffer, m_slaveMemory + m_writeAddress, m_totalBytes);

for (int i = 0; i < m_totalBytes; ++i) {
outputBuffer[i] = m_slaveMemory[m_writeAddress + i];
}


// ✅ Print the copied buffer
std::cout << "Copied outputBuffer contents:\n";
for (int i = 0; i < m_totalBytes; ++i) {
signed char val = static_cast<signed char>(outputBuffer[i]);
std::cout << "Byte " << i << ": " << static_cast<int>(val)
<< " (0x" << std::hex << static_cast<int>(static_cast<unsigned char>(val)) << std::dec << ")\n";
}




	/* Increment the counter by number of bytes written in the output range */
	m_sendDataCounter += totalBytes;

	g_objAmbaSlave->storeWriteResponse(m_response);
}





void AddressHandler::handleAxiSendOutputAddressFlag()
{
	//if(sendResult())
	//{
		// clear the dataReceived flag after sending the corresponding output
		//g_flags.dataReceived = false;
	//}
	std::cout << "The output ready flag is set correctly to 1 " <<std::endl;

	g_objAmbaSlave->storeWriteResponse(m_response);
}

/**
 * @brief: handle a read only register that is responsible on terminating the ARC application
 * 			
*/
void AddressHandler::handleAxiTerminateApp()
{
	// static uint8 data = 0;
	
	if (!g_flags.terminateARCApp)
	{
		data = 0;
		setReadDataResponse(&data, true);
	}
	else 
	{
		data = 1;
		setReadDataResponse(&data, true);
	}
}
bool AddressHandler::sendResult()
{
	int TxDataSz = 0;
	char tempBuff[m_sendDataCounter + 5]{'\0'};
	int counter = 4;
	// construct the TCP Pakcet 
	*(uint32*)tempBuff = m_sendDataCounter;	// set the total data bytes in the first four bytes of the TCP packet
	for (int idx = AXI_OUTPUT_BASE_ADDR; idx < AXI_OUTPUT_BASE_ADDR + m_sendDataCounter; ++idx)
	{
		tempBuff[counter++] = m_slaveMemory[idx];
	}

	send_recv_state_t TxState = server.sendData((char*)tempBuff, m_sendDataCounter + 4, TxDataSz);

	// check if the Transmission done successfully
	if(TxState == SEND_OR_RECV_SUCCESSFULLY)
	{
		m_slaveMemory[AXI_SEND_OUTPUT_ADDR_FLAG] = 0;
		m_sendDataCounter = 0;
		return true;
	}

	return false;
}
#endif

//Writes data in slave memory map
int AddressHandler::writeInMemory()
{    
	for (ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t idx = 0; idx < m_totalBytes; ++idx)
	{
		m_slaveMemory[m_writeAddress + idx] = *(m_writeData + idx);
	}

	return m_totalBytes;
	std::cout << "Verifying written memory values:\n";
for (int i = 0; i < m_totalBytes; ++i) {
    signed char value = static_cast<signed char>(m_slaveMemory[m_writeAddress + i]);
    std::cout << "Byte " << i << ": " << static_cast<int>(value)
              << " (0x" << std::hex << static_cast<int>(static_cast<unsigned char>(value)) << std::dec << ")\n";
}

   

}

void AddressHandler::setReadDataResponse(const void* data, bool setDataFlag)
{
	if (setDataFlag == true)
	{
		m_readData->FillWord64(*((uint64*)data));
	}

	else
	{
		for (int i=0; i< m_totalBytes; ++i)
		{
			m_readData->FillByteArray((const uint8_t*)(&m_slaveMemory[m_readAddress+i]), 1);
		}
	}
	
	for (int i=0; i<(m_burstLength+1); i++)
	{
		ZEBU_IP::XTOR_AMBA_DEFINES_SVS::enAXIResp rresp = ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXI_RESP_OKAY;
		m_response->AddResp(rresp);
	}

	g_objAmbaSlave->storeReadResponse(m_response, m_readData);
}

