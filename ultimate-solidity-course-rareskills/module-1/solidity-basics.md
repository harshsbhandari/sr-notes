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