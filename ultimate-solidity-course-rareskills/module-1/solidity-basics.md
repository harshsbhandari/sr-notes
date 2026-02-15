# Data Types

## Address

- An address is represented as a **hex string that has 40 characters in it, and always starts with 0x. A valid hex string contains the characters [0-9] or [a-f] inclusive.**
- Warning: be careful when typing addresses manually. Solidity will covert 0x1 into an address with the value 0x0000000000000000000000000000000000000001. If you have an **address with less than 40 hex characters, it will pad it with leading zeros.**
- If you create an address with **more than 40 characters, it won’t compile.**
- Note that the **40 characters do not include the leading 0x.**


## uint256

- The u means unsigned. It cannot represent negative numbers. The 256 means it **can store numbers up to 256 bits large, or 2^256-1.**
- That’s a very large number, big enough for pretty much everything you’ll need to do on the blockchain.
- **But if you make the number bigger, the code won’t compile.** 
- As you can imagine, a uint128 stores unsigned numbers that are up to 2^128 - 1 in size.

## Boolean

- This one is pretty obvious, it’s just like other languages. A bool variable **holds either a true or a false.** That’s it.


## Array

- Arrays & strings behave differently from the other Solidity datatypes.
- eg - 
```solidity
    contract ExampleContract {
        function useArrayForUint256(uint256[] calldata input)
            public
            pure
            returns (uint256[] memory) {
                return input;
        }
    }
```
- To get the **length of an array, use .length.**
- Arrays can be declared to have a fixed length
- eg -
```solidity
    contract ExampleContract {
        function productOfarray(uint256[5] calldata myArray)
        public
        pure
        returns (uint256) {
            uint256 last = myArray[4];
            return last;
        }
    }
```
- **If the function is passed an array of any size other than 5, it will revert.**
- Solidity **does not have a way to remove an item in the middle of a list and reduce the length by one. The following code is valid, but it does not change the length of the list.**
- eg - 
```solidity
    contract ExampleContract {
    
        uint256[] public myArray;
    
        function removeAt(uint256 index) public {
            delete myArray[index];
            // sets the value at 'index' to be zero
    
            // the following code is equivalent
            // myArray[index] = 0;
    
            // myArray.length does not change in either circumstance
        }
    }
```
- **If you want to remove an item and also reduce the length, you must do a “pop and swap”.**
- It removes the element at the index argument and swaps it with the last element in the array
- eg - 
```solidity
    contract ExampleContract {
    
        uint256[] public myArray;
    
        function popAndSwap(uint256 index) public {
            uint256 valueAtTheEnd = myArray[myArray.length - 1];
            myArray.pop(); // reduces the length;
            myArray[index] = valueAtTheEnd;
        }
    }
```

## String

- Strings behave very similarly to arrays. In fact, they are arrays under the hood (but with some differences).
- Strings **cannot be indexed**
- Strings **do not support length**. This is because **unicode characters can make the length ambiguous**, and Solidity represents **strings as a byte array, not a sequence of characters.**
- eg - 
```solidity
contract ExampleContract {
    function helloWorld(string calldata message)
        public
        pure
        returns (string memory) {
            message = "hello world";
            return message;
    }
}


```
- **Declaring arrays and strings inside a function, as opposed to in the argument or return value, has a different syntax.**

## Mapping

- **If you access a mapping with a key that has not been set, you will NOT get a revert. The mapping will just return the “zero value” of the datatype for the value**
- eg -
```solidity
    contract ExampleContract {
    
        mapping(uint256 => uint256) public myMapping;
    
        function setMapping(uint256 key, uint256 value)
            public {
                myMapping[key] = value;
        }
    
        function getValue(uint256 key)
            public
            view
            returns (uint256) {
                return myMapping[key];
        }
    }
```
- **ERC20 tokens use mappings to store how many tokens someone has**! They map an address to how many tokens someone owns.
- **ERC20 tokens are not stored in cryptocurrency wallets, they are simply a uint256 associated with your address in a smart contract. “ERC20 tokens” are simply a smart contract.**
- **Surprise 1: Mappings can only be declared as storage, you cannot declare them inside a function**
- **Surprise 2: Mappings cannot be iterated over**
- **Surprise 3: Mappings cannot be returned**

-- 

## What exactly is “forge” and “foundry” here?

- You can think of it like gulp or webpack for JavaScript or maven for Java or tox for Python. **Foundry is a development framework to make testing, development, and deployment easier.**
- One thing that is really cool about it is that **you can write unit tests in Solidity, so that makes testing easier.**

--

## Arithmetic

- Solidity does not have floats. 
- If you try to divide 5 by 2, you won’t get 2.5. You’ll get 2. Remember, uint256 is an unsigned integer. So any division you do is integer division.
- eg -
```solidity
    uint256 interest = 200 * 0.1; // fails, 0.1 is not valid
    
    // Equivalent for above code - 
    uint256 interest = 200 / 10;
```

- Note: Why doesn’t Solidity support floats? **Floats are not always deterministic, and blockchains must be deterministic otherwise nodes won’t agree on the outcomes of transactions.** For example, if you divide 2/3, some computers will return 0.6666, and others 0.66667. This disagreement could cause the blockchain network to split up! Therefore, Solidity does not allow floats.

- **Solidity does not underflow or overflow, it stops the execution**
- eg -
```solidity
    function subtract(uint256 x, uint256 y)
            public
            pure
            returns (uint256) {
                uint256 difference = x - y;
                return difference;
    }
```
- What happens if x is 2 and y is 5? You won’t get negative 3. **Actually, what happens is the execution will halt with a revert.**
- **Solidity doesn’t throw exceptions**, but you can think of a revert as the equivalent of an uncaught exception or a panic in other languages.
- It used to be the case **Solidity would allow overflows and underflows. This feature was added after Solidity version 0.8.0.**
- **If you want to allow underflow and overflow, you need to use an unchecked block**
- eg - 
```solidity
    uint256 x = 1;
    uint256 y = 2;
    
    unchecked {
        uint256 z = x - y; // z == 2**256 - 1
    }
```
- Note that **anything inside the unchecked block will not revert even if it overflows or underflows.**

-- 

## Switch

- **Solidity does not have a switch statement** like Java and C do.

--

## calldata and memory

- **Arrays can have unlimited size, so storing them on the execution stack, could lead to a stack overflow error.**
- Calldata is the **actual “transaction data” that is sent when someone transmits a transaction to the blockchain.**
- Calldata means **“refer to the data in the Ethereum transaction itself.”**
- When in doubt: **the function arguments for arrays and strings should be calldata and the function arguments for the return type should be memory.**
- There are **some exceptions to using calldata in a function argument**, but the **return type for an array should always be memory, never calldata, or the code won’t compile.** 

--

## State variables

- **Pure functions cannot access storage variables**
- **Pure functions are not aware of the blockchain state or anything that has happened in the past.**
- **Storage variable - These look like “class variables” in other languages, but don’t really behave like them. Think of them as variables that behave like a miniature database.**
- 'View' - it **views the blockchain state, think of view as read-only**
- Internal - **This means other smart contracts cannot see the value. Just because a variable is internal does not mean it is hidden. It’s still stored on the blockchain and anyone can parse the blockchain to get the value!**
- eg - 
```solidity
    contract ExampleContract {
    
        uint256 internal x;
    
        function setX(
            uint256 newValue
        )
        public {
                x = newValue;
        }
    
        // error: this function cannot be pure
        function getX()
            public
            pure
            returns (uint256) {
                return x;
        }
    }
```
- **When a variable is declared public, it means other smart contracts can read the value but not modify it, as public variables cannot be modified unless there is a function to change their value.**
- eg - 
```solidity
    contract ExampleContract {
        uint256 public x;
    
        function getX()
        public
        view
        returns (uint256) {
            return x;
        }
        // No one can change the value of 'x', because it is public
        // There has to be a setter function available too
    }
```
- **Public functions that do not have a view or pure modifier can change storage variables**

## msg.sender and address(this)

- Solidity has a mechanism to identify **who is calling the smart contract: msg.sender. msg.sender returns the address of who is invoking the smart contract function.**
- **address(this) - A smart contract its own address**

-- 

## constructor

- Smart contracts have a special function that is called at deployment time called the constructor. This is pretty similar to other object-oriented programming languages. Here is what it looks like
- eg -
```solidity
    contract ExampleContract {

        address public banker;
    
        constructor() {
            deployer = msg.sender;
        }
    }
//  or
    contract ExampleContract {
    
        address public banker;
    
        constructor(address _banker) {
            banker = _banker;
        }
    }
```
- Note that it’s **“constructor()” and not “function constructor()” and we don’t specify public because constructors can’t be modified with things like pure, view, public, and so forth. Also, constructors cannot return values.**
- If you wanted the banker to be configured by the person deploying the contract, then you could use it as a function argument.
- **Calldata cannot be used in constructor arguments.**

--

## require

- **The require statement forces the transaction to revert if some condition is not met.**
- eg -
```solidity
    contract ExampleContract {
        function mustNotBeFive(
            uint256 x
        )
            public
            pure
            returns (uint256) {
                require(x != 5, "five is not valid");
                return x * 2;
        }
    }
```

--

## ERC20 tokens

- eg -
```solidity
    contract ERC20 {
        string public name;
        string public symbol;
    
        mapping(address => uint256) public balanceOf;
        address public owner;
        uint8 public decimals;
    
        uint256 public totalSupply;
    
        // owner -> spender -> allowance
        // this enables an owner to give allowance to multiple addresses
        mapping(address => mapping(address => uint256))
            public allowance;
    
        constructor(
            string memory _name,
            string memory _symbol
        ) {
            name = _name;
            symbol = _symbol;
            decimals = 18;
    
            owner = msg.sender;
        }
    
        function mint(
            address to,
            uint256 amount
        )
            public {
                require(msg.sender == owner,
                    "only owner can create tokens");
                totalSupply += amount;
                balanceOf[owner] += amount;
        }
    
        function transfer(
            address to,
            uint256 amount
        )
            public
            returns (bool) {
                return helperTransfer(msg.sender, to, amount);
        }
    
        function approve(
            address spender,
            uint256 amount
        )
            public
            returns (bool) {
                allowance[msg.sender][spender] = amount;
    
                return true;
        }
    
        function transferFrom(
            address from,
            address to,
            uint256 amount
        )
            public
            returns (bool) {
                if (msg.sender != from) {
                    require(allowance[from][msg.sender] >= amount,
                        "not enough allowance");
    
                    allowance[from][msg.sender] -= amount;
                }
    
                return helperTransfer(from, to, amount);
        }
    
        function helperTransfer(
            address from,
            address to,
            uint256 amount
        )
            internal
            returns (bool) {
                require(balanceOf[from] >= amount,
                    "not enough money");
                require(to != address(0),
                    "cannot send to address(0)");
                balanceOf[from] -= amount;
                balanceOf[to] += amount;
    
                return true;
        }
    }
```
- If you’ve used ERC20 tokens in your wallet, no doubt you’ve seen instances where you have a fraction of the coin. How does that happen when unsigned integers have no decimals?
- The largest number a uint256 can represent is - 115792089237316195423570985008687907853269984665640564039457584007913129639935
- Let’s reduce the number a bit to make it more clear - 10000000000000000000000000000000000000000000000000000000000000000000000000000
- To be able to describe “decimals”, we say the 18 zeros to the right are the fractional part of the coin - 10000000000000000000000000000000000000000000000000000000000.000000000000000000
- Thus, if our ERC20 has 18 decimals, we can have at most - 10000000000000000000000000000000000000000000000000000000000 full coins, with the zeros to the right being decimals.
- 10 octodecillion should be enough for most applications, even countries that go into hyperinflation.
- The “units” of the currency are still integers, but the units are now very small values.
- **18 decimal places is pretty standard, but some coins use 6 decimal places.**
- **The decimal of the coin should not change, it’s just a function that returns how many decimals the coin has.**

--

## tuples

- It’s an array of fixed size, but the types inside of it can be a mixture.
- Note that tuples are implied. The keyword “tuple” never appears in Solidity.
- Tuples can also be “unpacked” to get the variables inside.
- eg -
```solidity
    contract ExampleContract {
    
        function getTopLeaderboardScore()
            public 
            pure 
            returns (address, uint256) {
                return (
                    0xd8da6bf26964af9d7eed9e03e53415d37aa96045, 
                    100
                );
        }
    
        function highestScoreIsOver9000()
            public 
            pure 
            returns (bool) {
                (address leader, uint256 score) = 
                    getTopLeaderboardScore();
    
                if (score > 9000) {
                    return true;
                }
            
                return false;  
        }
    }
```

## ABI

- When you call a function in a smart contract, you aren’t actually doing a “function call” per se, you are sending data to the contract with some information about which function should be executed.
- Function calls only happen inside the same execution context. Describing transactions as functions, however, is convenient. But we need to look behind the curtain to see exactly what is happening to really understand Solidity.
- When you “call a smart contract” you are sending data to the contract with instructions for how to execute.
There are many data encodings, JSON, XML, protobuf, etc. Solidity and Ethereum use the ABI encoding.
But what you need to know is that it always looks like a sequence of bytes.
Functions are identified as a sequence of four bytes. Our original byte sequence (0x92d62db5) had four bytes in it: 92, d6, 2d, b5.
- eg -
```solidity
    contract ExampleContract {
    
        function encodingXY(uint x, uint256 y)
            public
            pure
            returns (bytes memory) {
                return abi.encode(x,y);
        }
    
        function getATuple(bytes memory encoding)
            public
            pure
            returns (uint256, uint256) {
                (uint256 x, uint256 y) = abi.decode(encoding,
                    (uint256, uint256));
                return(x,y);
        }
    }
//    Also
    contract ExampleContract {
    
        function getEncoding(uint x)
        public
        pure
        returns (bytes memory) {
            return abi.encodeWithSignature("takeOneArg()", x);
        }
    
        function takeOneArg(uint256 x)
        public
        pure
        returns (bytes memory) {
            return msg.data;
        }
    }
```

--

## Calling other contracts

- **View functions are read only.** When you call the function of an arbitrary smart contract, you can’t know if it is read-only or not. Therefore, **solidity doesn’t let you specify a function as view if it calls another smart contract.**
- **Functions always return abi encoded bytes.** How does remix know to format strings as strings and numbers as numbers? Behind the scenes, it is doing the abi.decode operation that we are doing here.
- eg - 
```solidity
contract ExampleContract {
    function askTheMeaningOfLife(address source)
        public 
        returns (uint256) {
            (bool ok, bytes memory result) = source.call(
                abi.encodeWithSignature("meaningOfLifeAndAllExistence()")
            );
            require(ok, "call failed");

            return abi.decode(result, (uint256));
    }
}

contract AnotherContract {
    function meaningOfLifeAndAllExistence()
        public 
        pure 
        returns (uint256) {
            return 42;
    }
}
```

- eg -
```solidity
contract ExampleContract {
    function callAdd(address source, uint256 x, uint256 y)
        public 
        returns (uint256) {
            (bool ok, bytes memory result) = source.call(
                abi.encodeWithSignature("add(uint256,uint256)", x, y)
            );
            require(ok, "call failed");

            uint256 sum = abi.decode(result, (uint256));
            return sum;
    }
}

contract Calc {
    function add(uint256 x, uint256 y)
        public 
        returns (uint256) {
            return x + y;
    }
}
```

- Be careful to not have spaces in “add(uint256,uint256)”

## Token Exchange Mini Project

- eg-
```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract SkillCoin {
    mapping(address => uint256) public balance;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(uint256 amount) public {
        require(msg.sender != address(0));
        require(amount > 0);

        balance[msg.sender] += amount;
    }

    function approve(address provideAllowance, uint256 amount) public {
        require(msg.sender != address(0) && balance[msg.sender] > 0 && provideAllowance != address(0));
        allowance[msg.sender][provideAllowance] = amount;
    }

    function transferFrom(address sender, address receiver, uint256 amount) external returns(uint256) {
        require(sender != address(0) && receiver != address(0));
        require(balance[sender] >= amount && allowance[sender][receiver] >= amount);

        balance[sender] -= amount;
        balance[receiver] += amount;
        allowance[sender][receiver] -= amount;
        return amount;
    }

}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract RareCoin {
    mapping(address => uint256) public balance;
    address public receiver;

    constructor() {
        receiver = address(this);
    }

    function balanceOf() public view returns(uint256) {
        require(msg.sender != address(0) && balance[msg.sender] > 0);

        return balance[msg.sender];
    }

    function trade(address skillCoinAddress, uint256 amount) public {
        require(skillCoinAddress != address(0));
        address sender = msg.sender;
        (bool success, bytes memory result) =
                            skillCoinAddress.call
                (abi.encodeWithSignature("transferFrom(address,address,uint256)", sender, receiver, amount));

        require(success, "'Trade' - Transaction failed");

        balance[sender] += abi.decode(result, (uint256));
    }
}
```

--

## payable functions

- You can **send Ether in units of Wei, Gwei, Finney, or Ether.**
- **1 ether = 10^18 Wei.**
- **Unless functions have the payable modifier, they will revert if they receive Ether.**
- By the way, solidity provides a very convenient keyword for dealing with all the zeros involved with Ether. Both of these functions do the same thing, but one is more readable.
- eg -
```solidity
function moreThanOneEtherV1()
    public
    view
    returns (bool) {
        if (msg.sender.balance > 1 ether) {
            return true;
        }
        return false;
}

function moreThanOneEtherV2()
    public
    view
    returns (bool) {
        if (msg.sender.balance > 10**18) {
            return true;
        }
        return false;
}
```
- It is also **valid to make a constructor payable, if you want your smart contract to begin life with privilege and a headstart.** But you still need to explicitly send ether at construction time.
- **Just because a function is payable does not mean that the person calling the function has to send Ether.**
- You will use the **call function we described earlier, but with an extra “meta argument”.**
- eg - 
```solidity
contract ReceiveEther {
    function takeMoney()
        public
        payable {

    }

    function myBalance()
        public
        view
        returns (uint256) {
            return address(this).balance;
    }
}

contract SendMoney {
    constructor()
        payable {

    }

    function sendMoney(address receiveEtherContract)
        public
        payable {
            uint256 amount = myBalance();
            (bool ok, ) = receiveEtherContract.call{value: amount}(
                abi.encodeWithSignature("takeMoney()")
            );
            require(ok, "transfer failed");
    }

    function myBalance()
        public
        view
        returns (uint256) {
            return address(this).balance;
    }
}
```
- **'call' has a funny looking json-like object between call and the arguments. This is how ether is sent with a call. The “value” key determines the amount sent. This is zero by default.**
- **Payable functions cannot be view or pure. Changing the Ether balance of a smart contract is a “state change” on the blockchain.**

--

## Block.timestamp and Block.number

- **You get the unix timestamp on the block with the block.timestamp.**
- The number that comes back is the **number of seconds since January 1, 1970 UTC.**
- eg - 
```solidity
contract WhatTimeIsIt {

    function timestamp()
        public
        view
        returns (uint256) {
            return block.timestamp;
    }
}
```
- Ethereum progresses with blocks, and **whichever timestamp you get back is what the validator put into the block when they produced it.**

- **block.number - You can also know what block number you are on with this variable.**
- **Don’t use block.number to track time, only to enforce ordering of transactions.**
- eg - 
```solidity
contract ExampleContract {

    function whatBlockIsIt()
        external
        view
        returns (uint256) {
            return block.number;
    }
}
```
- **The code above will tell you which block the transaction happened on.**

--

## Emitting Events

- **If a function causes a state change, it should be logged.**
- Events **cannot be seen by other smart contracts.**
- **An event can have up to 3 indexed types, but there isn’t a strict limit on the number of unindexed parameters.**
- eg - 
```solidity
contract ERC20 {
    string public name;
    string public symbol;

    mapping(address => uint256) public balanceOf;
    address public owner;
    uint8 public decimals;

    uint256 public totalSupply;

    // owner -> spender -> allowance
    // this enables an owner to give allowance to multiple addresses
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(
        string memory _name,
        string memory _symbol
    ) {
        name = _name;
        symbol = _symbol;
        decimals = 18;

        owner = msg.sender;
    }

    function mint(
        address to,
        uint256 amount
    )
    public {
        require(msg.sender == owner, "only owner can create tokens");
        totalSupply += amount;
        balanceOf[owner] += amount;

        emit Transfer(address(0), owner, amount);
    }

    function transfer(
        address to,
        uint256 amount
    )
    public
    returns (bool) {
        return helperTransfer(msg.sender, to, amount);
    }

    function approve(
        address spender,
        uint256 amount
    )
    public
    returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
    public
    returns (bool) {
        if (msg.sender != from) {
            require(
                allowance[from][msg.sender] >= amount,
                "not enough allowance"
            );

            allowance[from][msg.sender] -= amount;
        }

        return helperTransfer(from, to, amount);
    }

    function helperTransfer(
        address from,
        address to,
        uint256 amount
    )
    internal
    returns (bool) {
        require(balanceOf[from] >= amount, "not enough money");
        require(to != address(0), "cannot send to address(0)");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }
}
```

-- 

## Inheritance

- Solidity behaves like an object oriented language and **allows for inheritance.**
- eg - 
```solidity
contract Parent {
    function theMeaningOfLife() 
        public 
        pure 
        returns (uint256) {
            return 42;
    }
}

contract Child is Parent {

}
```
- **When a “contract” is “another contract”, it inherits all it’s functionality.**
- Like other object oriented programming languages, **functions can be overridden.**
- eg - 
```solidity
contract Parent {
    function theMeaningOfLife() 
        public 
        pure 
        virtual 
        returns (uint256) {
            return 42;
    }
}

contract Child is Parent {
    function theMeaningOfLife() 
        public 
        pure 
        override 
        returns (uint256) {
            return 43;
    }
}
```
- **When a function overrides, it must match exactly, both in name, arguments, and return type.**
- Functions that override a parent’s function **must have an override modifier.**
- Note that **only virtual functions can be overridden. If you try to override a function that isn’t virtual, the code won’t compile.**
- **Solidity supports multiple inheritance.**
- There are two ways to **make a function not accessible from the outside world: giving them a private or internal modifier.**
  - **Private functions (and variables) cannot be “seen” by the child contracts.**
  - **Internal functions and variables can.**
- **The super keyword means “call the parent’s function.”**
- **Solidity won’t let you inherit from a parent contract without initializing it’s constructor.**
- eg - 
```solidity
contract Parent {
    string private name;

    constructor(string memory _name) {
        name = _name;
    }

    function getName() public view virtual returns (string memory) {
        return name;
    }
}

contract Child is Parent {

    // error, name hasn't been set!
    function getName() public view override returns (string memory) {
        return super.getName();
    }
}

// FIXED
contract Parent {
    string private name;

    constructor(string memory _name) {
        name = _name;
    }

    function getName() public view virtual returns (string memory) {
        return name;
    }
}

contract Child is Parent {

    // error, name hasn't been set!
    function getName() public view override returns (string memory) {
        return super.getName();
    }
}
```
- **You cannot inherit contract deployed on the blockchain.**
