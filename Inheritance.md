1. In Solidity, when a contract inherits from another contract (or multiple contracts), 
it **automatically gets access to all the public and internal variables and functions of the parent contracts**.

2. Do you have to implement all inherited functions?
**No, you don’t need to implement functions** unless:
- They are abstract (declared but not implemented) in the parent contract.
- You want to override an existing function to change or extend its behavior.

3. In Solidity, marking a contract as abstract means:
“This contract cannot be deployed directly — it’s meant to be inherited from.”
However, the reason for marking a contract abstract is not only the presence of abstract (unimplemented) functions.
There are actually two cases where a contract must or may be marked as abstract:
- Has abstract (unimplemented) functions
- **Implements all functions but is meant only as a base class**