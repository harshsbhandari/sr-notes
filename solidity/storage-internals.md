# Layout of State Variables in Storage and Transient Storage
- **In Solidity, one storage slot has a fixed size of 32 bytes (256 bits).** 

- State variables of contracts are stored in storage in a compact way such that **multiple values sometimes use the same storage slot.** 
- Except for dynamically-sized arrays and mappings (see below), **data is stored contiguously item after item starting with the first state variable, which is stored in slot 0.** 
- For each variable, a **size in bytes is determined according to its type.** 
- **Multiple, contiguous items that need less than 32 bytes are packed into a single storage slot if possible**, according to the following rules:

1. The first item in a storage slot is stored lower-order aligned.
2. Value types use only as many bytes as are necessary to store them.
3. If a value type does not fit the remaining part of a storage slot, it is stored in the next storage slot.
4. **Structs and array data always start a new slot and their items are packed tightly according to these rules.**
5. **Items following struct or array data always start a new storage slot.**

- For contracts that use inheritance, the **ordering of state variables is determined by the C3-linearized order of contracts starting with the most base-ward contract.**
- If allowed by the above rules, **state variables from different contracts do share the same storage slot.**

--

- If a contract specifies a **custom storage layout, the slots assigned to static storage variables are shifted according the value defined as the layout base.**
- The **custom layout is specified in the most derived contract** and, following the order explained above, **starting from the most base-ward contract’s variables, all storage slots are adjusted.**
- eg - 
```solidity
    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.29;
    
    struct S {
        int32 x;
        bool y;
    }
    
    contract A {
        uint a;
        uint128 transient b;
        uint constant c = 10;
        uint immutable d = 12;
    }
    
    contract B {
        uint8[] e;
        mapping(uint => S) f;
        uint16 g;
        uint16 h;
        bytes16 transient i;
        S s;
        int8 k;
    }
    
    contract C is A, B layout at 42 {
        bytes21 l;
        uint8[10] m;
        bytes5[8] n;
        bytes5 o;
    }
    /*
    * Storage - 
    * 42 [aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa]
    * 43 [eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee]
    * 44 [ffffffffffffffffffffffffffffffff]
    * 45 [                            hhgg]
    * 46 [                           yxxxx]
    * 47 [          lllllllllllllllllllllk]
    * 48 [                      mmmmmmmmmm]
    * 49 [  nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn]
    * 50 [                      nnnnnnnnnn]
    * 51 [                           ooooo] 
    *
    * Transient Storage - 
    * 00 [iiiiiiiiiiiiiiiibbbbbbbbbbbbbbbb]
    */
```
1. The storage layout **starts with the inherited state variable a stored directly inside the base slot (slot 42).** 
2. Transient, constant and immutable variables are **stored in separate locations, and thus, b, i, c and d have no effect on the storage layout.** 
3. Then we get to the dynamic array e and mapping f. They **both reserve a whole slot whose address will be used to calculate the location where their data is actually stored. The slot cannot be shared with any other variable, because the resulting addresses must be unique.** 
4. The next two variables, g and h, need **2 bytes each and can be packed together into slot 45, at offsets 0 and 2 respectively.**
5. Since s is a struct, its two members are packed contiguously, each taking up 5 bytes. **Even though they both would still fit in slot 45, structs and arrays always start a new slot.** Therefore, s is placed in slot 46.
6. The next variable, k, in slot 47.
7. Base contracts, on the other hand, **can share slots with derived ones, so l does not require an new one.**
8. Then variable m, which is an array of 10 items, gets into slot 48 and takes up 10 bytes. n is an array as well, but due to the size of its items, cannot fill its first slot perfectly and spills over to the next one. 
9. Finally, variable o ends up in slot 51, even though it is of the same type as items of n. As explained before, **variables after structs and arrays always start a new slot.**

- **Note that the storage specifier affects A and B only as a part of C’s inheritance hierarchy. **When deployed independently, their storage starts at 0. (if contract c never existed)**
```solidity
    /*
     * 
     * Storage layout of a - 
     * 00 [aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa]
     *
     * Storage layout of b - 
     * 00 [eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee]
     * 01 [ffffffffffffffffffffffffffffffff]
     * 02 [                            hhgg]
     * 03 [                           yxxxx]
     * 04 [                               k]
     */
```

--

https://rareskills.io/post/evm-solidity-storage-layout
# Types of Storage

- Variables in a smart contract store their value in two primary locations:

## 1. Storage (mutable) 

- The **storage holds mutable information. Variables that store their value in the storage are called state variables or storage variables.**
- Their **value persists in the storage indefinitely, until further transactions alter them or the contract self-destructs.**
- Storage variables are variables of all types that are declared within the **global scope of a contract (except for immutable and constant variables)**.
- When we interact with a storage variable, **under the hood, we are actually reading and writing from the storage, specifically at the storage slot where the variable keeps its value.**

## 2. Bytecode (immutable)
- The **bytecode stores immutable information. These include the values of immutable and constant variable types, as well as the compiled source code.**
- eg -
```solidity
    contract ImmutableVariables {
        uint256 constant myConstant = 100;
        uint256 immutable myImmutable;
    
        constructor(uint256 _myImmutable) {
            myImmutable = _myImmutable;
        }
    
        function doubleX() public pure returns (uint256) {
            uint256 x = 20;
            return x * 2;
        }
    }
```

## Storage slots

- A smart contract’s storage is organized into storage slots. **Each slot has a fixed storage capacity of 256 bits or 32 bytes ( 256 / 8 = 32 ).**
- **Storage slots are indexed from 0 to (2^256 - 1). These numbers act as a unique identifier for locating individual slots.**
- The solidity **compiler allocates storage space to storage variables in a sequential and deterministic manner, based on their declaration order within the contract.**
- A variable **cannot change its storage slot once the contract is deployed to the blockchain.**
- All storage variables **default to zero** until they are explicitly set.

## Inside storage slots: 256-bit data

- Individual storage slots store data in 256-bit format; It **stores the bit representation of a storage variable’s value.**
- Reading the contents of a storage slot in raw 256 bit format is less human-readable, therefore, **solidity devs usually read it in hexadecimal format.**
- The 256 bit of ones and zeros can be reduced to just 64 hexadecimal numbers. 1 hexadecimal character represents 4 bits. 2 hexadecimal characters represent 1 byte. 

## Storage Packing

- Data types that utilise less space, they can be packed together within the same storage slot.
- **Solidity packs variables in storage slots starting from the least significant byte (right most byte) and progresses to the left.**
- **When declared in sequence, smaller sized variables live in the same storage slot if their total size is less than 256 bits or 32 bytes.**
- eg - 
```solidity
    contract AddressVariable {
        address owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
        // new
        bool Boolean = true;
        uint32 thirdvar = 5_000_000;
    }
    /*
     * All 3 state variables will be stored in the slot 0 of the Storage, ie :
     * 1. 7 bytes - free space
     * 2. 4 bytes - thirdvar
     * 3. 1 byte - Boolean
     * 4. 20 bytes - owner
     */
```
- If a variable’s value cannot fit entirely into the remaining space of the current storage slot, it will be stored in the next available slot.

## Storage Slot Manipulation in Assembly (YUL)

- Low level assembly (Yul) gives a higher degree of freedom in performing storage related operations. It **allows us to directly read and write from individual storage slots and access a storage variable’s properties.**
- There are two opcodes related to storage in Yul: sload() & sstore().
1. **sload() - reads the value stored by a specific storage slot.**
2. **sstore() - updates the value of a specific storage slot with a new value.**

- Two other important Yul keywords are .slot and .offset.
1. **.slot - returns the location within the storage slots, it tells us at which storage slot a variable keeps its value.**
2. **.offset - returns the byte offset of the variable.**
- eg - 
```solidity
    contract StorageManipulation {
        uint256 x = 11;
        uint256 y = 22;
        uint256 z = 33;
    }

    /*
    * x.slot - returns a value of 0 , which corresponds to the storage slot where x stores its state—slot 0.
    */
    function getSlotX() external pure returns (uint256 slot) {
        assembly {// yul            
            slot := x.slot // returns slot location of x        
        }
    }

    /*
    * The function readSlotX() retrieves the 256 bit data stored in x.slot (slot 0) and returns it in uint256 format, which equals 11.
    */
    function readSlotX() external view returns (uint256 value) {
        assembly {
            value := sload(x.slot)
        }
    }
    /*
     * sload(0) reads from slot 0, which stores the value of 11.
     * sload(1) reads from slot 1, which stores the value of 22.
     * sload(2) reads from slot 2, which stores the value of 33.
     * sload(3) reads from slot 3, which stores nothing, it is still in its default state.
     */
    /*
     * The function sloadOpcode(slotNumber) - allows us to read the value of any arbitrary storage slot. It then returns the value in uint256 format.
     */
    function sloadOpcode(uint256 slotNumber) external view returns (uint256 value) {
        assembly {
            value := sload(slotNumber)
        }
    }
```
- **sload() does not perform a type check.**
- **In assembly, every variable is essentially treated as a bytes32 type. Outside of the assembly scope, the variable will resume its original type and format the data accordingly.**

## Writing to a storage slot using the sstore() opcode

- Yul gives us **direct access to modify the value of a storage slot using the sstore() opcode.**
- sstore(slot, value) stores a 32-byte long value directly to a storage slot. The opcode takes two parameters, slot and value:
1. slot: This is the **targeted storage slot which we are writing to.**
2. value: The **32-byte value to be stored at the specified storage slot.** If the value is less than 32 bytes, it will be left padded with zeroes
sstore(slot, value) overwrites the entire storage slot with a new value.

- eg -
```solidity
    contract WriteStorage {
        uint256 public x = 11;
        uint256 public y = 22;
        address public owner;
    
        constructor(address _owner) {
            owner = _owner;
        }
    
        // sstore() function
        /*
         * Both sstore_x(newVal) and set_x() perform the same function: They update the value of x with a new value.
         */
        function sstore_x(uint256 newval) public {
            assembly {
                sstore(x.slot, newval)
            }
        }
    
        // normal function
        function set_x(uint256 newval) public {
            x = newval;
        }
    }
```
- **sstore() also does not type check.**

## Manipulating storage packed variables in Yul Part 2

- sstore and sload **operate on lengths of 32 bytes.** This is **convenient when dealing with uint256 type as the entire 32 bytes read or written correspond directly to the uint256 variable.**
- The situation becomes more **complex when dealing with variables that are packed within the same storage slot.**
- **Their byte sequence occupies only a portion of the 32 bytes and in assembly, we do not have an opcode to directly modify or read from their byte sequence in storage.**