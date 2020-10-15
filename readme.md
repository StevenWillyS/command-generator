# Command Generator

A shell script to generate command files based on the Command Design Pattern in Java.

## Why

Because it's a hassle to create a new command files

## Setup

Add the script to your environment variable folder

## Usage

### Generate basic new command files

```bash
GenerateBasicCommand <COMMAND_NAME>
```

e.g:
```bash
GenerateBasicCommand CreateOrder
```

This will generate the following command files in the respective directory, with their needed imports

```
CreateOrderCommand.java
CreateOrderCommandImpl.java
CreateOrderCommandImplTest.java
CreateOrderCommandRequest.java
CreateOrderWebResponse.java
```
