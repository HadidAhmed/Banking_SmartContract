    // SPDX-License-Identifier: GPL-3.0

    pragma solidity >=0.7.0 <0.9.0;

    contract banksystem{
     
        address owner;  
        uint256 balanceReceived;
        uint16 client_count;


    
        mapping(address=>uint256) UserAccount;
        mapping(address=>bool) Usercheck;
        
    // Constructor is "payable" so it can receive the initial funding of 50 Ether. Allow owner to start the bank
        constructor() payable
        {
            require( msg.value >= 50 ether,"Minimum 50 ETHS required to start the bank");
            balanceReceived += msg.value;
            owner = msg.sender;
            client_count= 0;
        }
       
    // Restricts execution by owner only to use with function
        modifier onlyOwner {
         require(msg.sender == owner);
         _;
        }

    // To know who owns the bank 
        function Bank_Owner()public view returns(address){

            return owner;
        }

    // Total balance Received by the bank so far
        function Total_BalanceReceived()public view onlyOwner returns(uint256){

            return balanceReceived;
        }

    // Current balance the bank have and restrict to the owner
        function Current_Balance() public view onlyOwner returns(uint256) {

            //require(owner == msg.sender,"only owner can view the Total amount");
            return address(this).balance;
        }

    // Total accounts opens in bank and restrict to owner
        function Total_Accounts() public view onlyOwner returns(uint16){

            return client_count;
        }

    // Check Account exist or not
        function Account_Status(address _account2) public view returns(bool) {

            return Usercheck[_account2];

        }

    // create a account with the bank, giving 1ETHER to first 5 account as a reward
    // Retrun the status
        function Create_Account() public payable returns(string memory)
        {
            require(Usercheck[msg.sender] == false,"Account Already Exist" );
            require(msg.value > 0 ether,"For account opening you must have deposit money");
            UserAccount[msg.sender] = msg.value;
            balanceReceived += msg.value;   
            Usercheck[msg.sender] = true;
         
            if(client_count < 5)
            {
                client_count ++;
                UserAccount[msg.sender] += 1 ether;
            }
            return 'Account Created';
        }

    // Deposit Ether into bank
    // Return the balance of the bank after deposit
        function Deposit_Funds() public payable returns(uint256)
        {
            require(Usercheck[msg.sender] == true , "Please open the account first");
            UserAccount[msg.sender] += msg.value;
            balanceReceived += msg.value;
            return UserAccount[msg.sender];
        }

    // Withdraw ether from bank
    // Withdraw enter amount you want to withdraw
    // Retrun the Withdraw status
        function Withdraw_Funds(uint256 _amount) public payable returns(string memory)
        {
            //address payable _account1 = payable(msg.sender);
            require(UserAccount[msg.sender] >= _amount , "You have insufficent balance");
            require(Usercheck[msg.sender] == true , "Please open the account first");
            require(_amount > 0 ether, "Amount should be greater than 0");
            UserAccount[msg.sender] -= _amount;
            payable(msg.sender).transfer(_amount);
            return 'Withdrawl sucessfull';
        }

    // Check account balance
        function Balance_Inquiry(address _address1) public view returns(uint256)
        {
            require((Usercheck[msg.sender] == true) || (owner == msg.sender), "This account Doesn't exist");
            return UserAccount[_address1];
        }

    // Transfer funds from existing account to other existing account
        function Transfer_Funds(address  payable _to,uint256 _amount1) public payable returns(string memory)
        { 
            require(_amount1 > 0, "amount should be greater than zero");
            require(UserAccount[msg.sender] >= _amount1,"insufficent balance");
            require(((Usercheck[_to] == true) && (Usercheck[msg.sender] == true)),"To sends the funds bank account is required for both sender and receiver"); 
            UserAccount[msg.sender] -= _amount1;
            _to.transfer(_amount1);
            UserAccount[_to] += _amount1;
            return 'Amount send sucessfully';
        }

    // Depositors can close the account whenever they want
    // All the deposit money send back to the depositor acccount
        function Closing_Account() public payable returns(string memory)
        {
            require(Usercheck[msg.sender] == true,"This account Doesn't exist");
            payable(msg.sender).transfer(UserAccount[msg.sender]);
            UserAccount[msg.sender] = 0; 
            Usercheck[msg.sender] = false;
            client_count--;
            return 'Account is close sucessfully';
        }

    // Bank Owner can close the account and upon closing all the balance should return to the owner
        function Closing_Bank() public onlyOwner {
 
            selfdestruct(payable(owner));
        }
    }
