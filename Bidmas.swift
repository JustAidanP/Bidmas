#!/usr/bin/swift
import Foundation
//Given an input calculation, will return the bidmas result

//------Enumerators------
//Stores an enum of every possible token
enum Tokens:Int{
    case OPEN_BRACKET = 0
    case CLOSE_BRACKET = 1
    case OPER_ADD = 2
    case OPER_SUBTRACT = 3
    case OPER_MULTIPLY = 4
    case OPER_DIVIDE = 5
    case OPER_POWER = 6
    case FUNC_SIN = 7
    case FUNC_COS = 8
    case FUNC_TAN = 9
    case SYMB_DIGIT = 10
    case SYMB_DOT = 11
    case ID = 12
    case EXPRESSION = 13
    case INVALID = 14
}

//------Structures------
//Defines a token structure
//Arguments:    -Aa token       -tokens
//              -An operand     -Any
struct Token{
    var token:Tokens
    var operand:Int = 0
}
//Defiens a node for the node tree
struct Node{
    //Stores this nodes token
    var token:Token
    //Stores a list of children nodes
    var children:[Node] = []

    //------Procedures/Functions------
    //Gets this nodes values
    func getValue() -> Float{
        //If the node is an ID token, it returns the value of the ID
        if self.token.token == .ID{
            return VariableContainer.getValue(self.token.operand)
        }
        //Gets the previous nodes values
        switch self.token.token{
            case .OPER_ADD:
                return self.children[0].getValue() + self.children[1].getValue()
            case .OPER_SUBTRACT:
                return self.children[0].getValue() - self.children[1].getValue()
            case .OPER_MULTIPLY:
                return self.children[0].getValue() * self.children[1].getValue()
            case .OPER_DIVIDE:
                return self.children[0].getValue() / self.children[1].getValue()
            case .OPER_POWER:
                return pow(self.children[0].getValue(), self.children[1].getValue())
            case .FUNC_SIN:
                return sin(self.children[0].getValue())
            case .FUNC_COS:
                return cos(self.children[0].getValue())
            case .FUNC_TAN:
                return tan(self.children[0].getValue())
            case .EXPRESSION:
                //Evaluates the corresponding expression node
                return ExpressionNodeContainer.getValue(self.token.operand).getValue()
            default:
                return 0
        }
    }
    func log(indentation:Int = 0){
        var pre = ""
        for _ in 0..<indentation{
            pre = pre + "    "
        }
        print(pre, self.token.token)
        if self.token.token == .EXPRESSION{
            ExpressionNodeContainer.getValue(self.token.operand).log(indentation: indentation + 1)
        }
        else{
            for child in self.children{
                child.log(indentation: indentation + 1)
            }
        }
    }
}
//------Extensions------
extension Token: Equatable{
    public static func ==(lhs: Token, rhs: Token) -> Bool{
        return lhs.token == rhs.token && lhs.operand == rhs.operand
    }
}
extension Node: Equatable{
    public static func ==(lhs: Node, rhs: Node) -> Bool{
        return lhs.token == rhs.token && (lhs.children == rhs.children)
    }
}
//------Classes------
class Expression{
    //------Variables/Constants------
    //Stores the tokens associated with the Expression
    var tokens:[Token] = []

    //------Procedures/Functions-------
    //Adds a new token to the token list
    func pushToken(token:Token){
        self.tokens.append(token)
    }
    //Generates a node tree for the expression
    static func parse(_levelTokens:[Token]) -> Node{
        //Stores the list of priority expressions
        let operations:[Tokens] = [.OPER_SUBTRACT, .OPER_ADD, .OPER_MULTIPLY, .OPER_DIVIDE, .OPER_POWER, .FUNC_SIN, .FUNC_COS, .FUNC_TAN, .ID, .EXPRESSION]
        //Stores a searching pointer into the operations list
        var searchPointer = 0
        //Does a pass through the tokens for each operation in order of priority
        while searchPointer != operations.count{
            //Will pass through each token, and find the highest prority operation
            for i in 0..<_levelTokens.count{
                //Will find the token being searched, the list is searched through in reverse order
                let index = _levelTokens.count - i
                let token = _levelTokens[index - 1]
                //Will check if the token is the operation
                if token.token == operations[searchPointer]{
                    //Generates a node for the operation
                    var node = Node(token: token)
                    //If the token is an ID or an Expression, it will return the node without children
                    if token.token == .ID || token.token == .EXPRESSION{return node}
                    //Checks if the token is sin, cos or tan
                    if token.token == .FUNC_SIN || token.token == .FUNC_SIN || token.token == .FUNC_SIN{
                        //Assigns the right side of the expression to the children
                        //This can be done as the tokens are reversed through, as a result, there won't be conflicts
                        node.children = [Expression.parse(_levelTokens: Array(_levelTokens[index...]))]
                        return node
                    }
                    //Parses the left side of the operator and gets a node tree
                    let childNode_0 = Expression.parse(_levelTokens: Array(_levelTokens[..<(index - 1)]))
                    //Parses the right side of the operator and gets a node tree
                    let childNode_1 = Expression.parse(_levelTokens: Array(_levelTokens[index...]))
                    node.children = [childNode_0, childNode_1]
                    return node
                }
            }

            //Will switch to the next operation
            searchPointer += 1
        }
        //If there was no node generated, it return an ID with operand of 0
        return Node(token: Token(token: .ID, operand: 0))
    }
}
//Handles all calculation variables
class VariableContainer{
    //------Variables/Constants------
    //Stores a list of variables
    static var container:[Float] = []
    
    //------Procedures/Funcitons------
    //Adds a new value to the container and returns the index
    //Arguments:    -A value to add             -Float
    //Return:       -An index into the array    -Int
    static func addValue(_ value:Float) -> Int{
        //Adds the value to the container
        if !VariableContainer.container.contains(value){VariableContainer.container.append(value)}
        //Returns the index of the value
        return VariableContainer.container.firstIndex(of: value)!
    }
    //Returns the value at a specified index
    //Arguments:    -An index                   -Int
    //Return:       -A value                    -Float
    static func getValue(_ index:Int) -> Float{
        return VariableContainer.container[index]
    }
    //Removes all values from the container
    static func removeAll(){
        VariableContainer.container = []
    }
}
//Stores all expression nodes
class ExpressionNodeContainer{
    //------Variables/Constants------
    //Stores a list of expressions
    static var container:[Node] = []
    
    //------Procedures/Funcitons------
    //Adds a new value to the container and returns the index
    //Arguments:    -A value to add             -Node
    //Return:       -An index into the array    -Int
    static func addValue(_ value:Node) -> Int{
        //Checks if the node is in the 
        //Adds the value to the container
        if !ExpressionNodeContainer.container.contains(value){ExpressionNodeContainer.container.append(value)}
        //Returns the index of the value
        return ExpressionNodeContainer.container.firstIndex(of: value)!
    }
    //Returns the value at a specified index
    //Arguments:    -An index                   -Int
    //Return:       -A value                    -Node
    static func getValue(_ index:Int) -> Node{
        return ExpressionNodeContainer.container[index]
    }
    //Removes all values from the container
    static func removeAll(){
        ExpressionNodeContainer.container = []
    }
}

//------Variables/Constants------
//Stores a tokenised list of the calculation
var tokenisedList:[Token] = []

//------Procedures/Functions------
//Tokenises a string
func lexicalAnalysis(_ text:String){
    //Iterates through every character, generating a corresponding token
    for character in text{
        switch character{
            case "(":
                tokenisedList.append(Token(token: Tokens.OPEN_BRACKET))
                break
            case ")":
                tokenisedList.append(Token(token: Tokens.CLOSE_BRACKET))
                break
            case "+":
                tokenisedList.append(Token(token: Tokens.OPER_ADD))
                break
            case "-":
                tokenisedList.append(Token(token: Tokens.OPER_SUBTRACT))
                break
            case "*":
                tokenisedList.append(Token(token: Tokens.OPER_MULTIPLY))
                break
            case "/":
                tokenisedList.append(Token(token: Tokens.OPER_DIVIDE))
                break
            case "^":
                tokenisedList.append(Token(token: Tokens.OPER_POWER))
            case "s":
                tokenisedList.append(Token(token: Tokens.FUNC_SIN))
            case "c":
                tokenisedList.append(Token(token: Tokens.FUNC_COS))
            case "t":
                tokenisedList.append(Token(token: Tokens.FUNC_TAN))
            case ".":
                tokenisedList.append(Token(token: Tokens.SYMB_DOT))
                break
            case " ":
                break
            default:
                //Checks if the character is an Int
                if let digit = Int(String(character)){tokenisedList.append(Token(token: Tokens.SYMB_DIGIT, operand: digit))}
                //Else it is an invalid character
                else{
                    tokenisedList.append(Token(token: Tokens.INVALID))
                    print("ERROR: Character \(character) is invalid")
                }
        }
    }
    //Stores a series of digits as characters
    var digits:String = ""
    //Stores the index of the start of a number
    var pointer:Int = -1
    //Stores the index into the list
    var index:Int = 0
    //Converts any digits into a number
    while index < tokenisedList.count{
        let token = tokenisedList[index]
        //Checks if the token is a digit
        if token.token == .SYMB_DIGIT{
            //Adds the digit to the operand
            digits = digits + String(token.operand)

            //Sets the pointer to the start of the number, if it isn't already
            if pointer == -1{pointer = index}
            //Removes the token from the tokenisedList
            tokenisedList.remove(at: index)
            //Adds an ID to the tokenisedList if there isn't one there at the pointer
            if tokenisedList[pointer].token != .ID{
                tokenisedList.insert(Token(token: Tokens.ID), at: pointer)
                //Iterates the index by one
                index += 1
            }
            //Continues onto the next token, leaving the index to the current index to account for the remove one
            continue
        }else if token.token == .SYMB_DOT{
            if digits.contains("."){print("ERROR: extra dot included")}
            digits = digits + "."

            //Sets the pointer to the start of the number, if it isn't already
            if pointer == -1{pointer = index}
            //Removes the token from the tokenisedList
            tokenisedList.remove(at: index)
            //Continues onto the next token, leaving the index to the current index to account for the removne one
            continue
        }
        //Checks if the number should be negative, this only happens if the previous token isn't a number or a close bracket
        else if token.token == .OPER_SUBTRACT{
            //Finds the last token if it exists
            let lastToken = (index == 0) ? .INVALID : tokenisedList[index - 1].token
            //Makes sure that the number is supposed to be negative
            if lastToken != .ID && lastToken != .CLOSE_BRACKET && lastToken != .INVALID{
                digits = digits + "-"

                //Sets the pointer to the start of the number, if it isn't already
                if pointer == -1{pointer = index}
                //Removes the token from the tokenisedList
                tokenisedList.remove(at: index)
                //Continues onto the next token, leaving the index to the current index to account for the removne one
                continue
            }
        }
        //ID AT index OPERAND SET FLOAT(digits) IF pointer == -1 and digits != ""
        if pointer != -1 && digits != ""{
            //Sets the operand of the ID at the pointer to the number
            if tokenisedList[pointer].token == .ID{
                tokenisedList[pointer].operand = VariableContainer.addValue(Float(digits)!)
            }
        }
        //Runs if the loop wasn't continued
        //Adds the number to the tokenisedList at the correct index
        // if pointer != -1{print(digits); tokenisedList.insert(Token(token: Tokens.ID, operand: VariableContainer.addValue(Float(digits)!)), at: pointer)}

        digits = ""
        //Sets the pointer to the default index
        pointer = -1
        index += 1
    }
    //Adds the last number if it exists
    if digits != ""{
        print(digits)
        tokenisedList.insert(Token(token: Tokens.ID, operand: VariableContainer.addValue(Float(digits)!)), at: pointer)}
}

//Parses a list of expressions into tokens
func parseExpression(tokenList:[Token]) -> Node{
    //Creates an expression stack to be pushed to, by default has the outer expression
    var expressionStack:[Expression] = [Expression()]
    for token in tokenList{
        //Checks if an expression has been started
        if token.token == .OPEN_BRACKET{
            //Creates a new expression and pushes it to the expressionStack
            expressionStack.append(Expression())
        }
        //Checks if an expression has ended
        else if token.token == .CLOSE_BRACKET{
            //------GENERATE NODE TREE FOR EXPRESSION------

            //Generates a node tree for the given expression and adds it to the expression list
            let nodeID = ExpressionNodeContainer.addValue(Expression.parse(_levelTokens: expressionStack.last!.tokens))

            //Removes the last expression from the expression stack
            expressionStack.remove(at: expressionStack.count - 1)

            //Adds an expression token to the current expression, with an operand of the last expressions parsed node ID
            expressionStack.last!.pushToken(token: Token(token: .EXPRESSION, operand: nodeID))
        }
        else{
            //Adds the token to the last expression
            expressionStack.last!.pushToken(token: token)
        }
    }
    //Evaluates the last expression and returns it
    return Expression.parse(_levelTokens: expressionStack[0].tokens)
}


let arg = CommandLine.arguments[1]
if arg != ""{
    //Creates a node tree from the given calculation
    lexicalAnalysis(arg)

    // //Parses the calculation
    let nodeTree = parseExpression(tokenList: tokenisedList)

    nodeTree.log()
    
    // //Prints the result of the calculation
    print(nodeTree.getValue())
}else{
    print("Please add a calculation enclosed in quotation marks")
}