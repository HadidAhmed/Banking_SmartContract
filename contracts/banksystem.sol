    // SPDX-License-Identifier: GPL-3.0

    pragma solidity >=0.7.0 <0.9.0;

    contract banksystem{

        address owner;
        uint256 balanceReceived;
        uint16 client_count;



        mapping(address=>uint256) UserAccount;
        mapping(address=>bool) Usercheck;
      //  mapping(address=>uint256)public _balances;



        constructor() payable
        {
            require( msg.value >= 50 ether,"Minimum 50 ETHS required to start the bank");
            balanceReceived += msg.value;
            owner = msg.sender;
            client_count= 0;
        }

        modifier onlyOwner {
         require(msg.sender == owner);
         _;
        }

        function Bank_Owner()public view returns(address){

            return owner;
        }

        function Total_BalanceReceived()public view onlyOwner returns(uint256){

            return balanceReceived;
        }

        function Current_Balance() public view onlyOwner returns(uint256) {

            //require(owner == msg.sender,"only owner can view the Total amount");
            return address(this).balance;
        }

        function Total_Accounts() public view onlyOwner returns(uint16){

            return client_count;
        }

        function Account_Status(address _account2) public view returns(bool) {

            return Usercheck[_account2];

        }


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


        function Deposit_Funds() public payable
        {
            require(Usercheck[msg.sender] == true , "Please open the account first");
            UserAccount[msg.sender] += msg.value;
            balanceReceived += msg.value;
        }


        function Withdraw_Funds(uint256 _amount) public payable returns(string memory)
        {
            //address payable _account1 = payable(msg.sender);
           // require(owner == msg.sender, "only bank can withdraw to clients");
            require(UserAccount[msg.sender] >= _amount , "You have insufficent balance");
            require(Usercheck[msg.sender] == true , "Please open the account first");
            require(_amount > 0 ether, "Amount should be greater than 0");
            UserAccount[msg.sender] -= _amount;
            payable(msg.sender).transfer(_amount);
           // UserAccount[_account1] -= _amount;
            return 'Withdrawl sucessfull';
        }


        function Balance_Inquiry(address _address1) public view returns(uint256)
        {
            require((Usercheck[msg.sender] == true) || (owner == msg.sender), "This account Doesn't exist");
            return UserAccount[_address1];
        }


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


        function Closing_Account() public payable returns(string memory)
        {
            require(Usercheck[msg.sender] == true,"This account Doesn't exist");
            payable(msg.sender).transfer(UserAccount[msg.sender]);
            UserAccount[msg.sender] = 0; 
            Usercheck[msg.sender] = false;
            client_count--;
            return 'Account is close sucessfully';
        }


        function Closing_Bank() public onlyOwner {
           
           // require(msg.sender == owner,"you are not the owner");
            selfdestruct(payable(owner));
        }

        // function withdraw() public payable 
        // {
        //     address payable _too = payable(msg.sender);
        //     _too.transfer(address(this).balance);
        // }
    }