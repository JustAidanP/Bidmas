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
    case INVALID = 13
}

//------Structures------
//Defines a token structure
//Arguments:    -Aa token       -tokens
//              -An operand     -Any
struct Token{
    var token:Tokens
    var operand:Any = 0;
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
            if let id = self.token.operand as? Int{
                return VariableContainer.getValue(id)
            }
            return 0
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
            default:
                return 0
        }
    }
}
//------Classes------
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
    //Prints the container
    static func logContainer(){
        print("Index, Value")
        for index in 0..<VariableContainer.container.count{
            print("\(index), \(VariableContainer.container[index])")
        }
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
                if let _ = Int(String(character)){tokenisedList.append(Token(token: Tokens.SYMB_DIGIT, operand: character))}
                //Else it is an invalid character
                else{
                    tokenisedList.append(Token(token: Tokens.INVALID, operand: character))
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
            if let operand = token.operand as? Character{digits = digits + String(operand)}

            //Sets the pointer to the start of the number, if it isn't already
            if pointer == -1{pointer = index}
            //Removes the token from the tokenisedList
            tokenisedList.remove(at: index)
            //Accounts for removing the token
            index -= 1
        }else if token.token == .SYMB_DOT{
            if digits.contains("."){print("ERROR: extra dot included")}
            digits = digits + "."

            //Sets the pointer to the start of the number, if it isn't already
            if pointer == -1{pointer = index}
            //Removes the token from the tokenisedList
            tokenisedList.remove(at: index)
            //Accounts for removing the token
            index -= 1
        }
        //Checks if the number should be negative, this only happens if the previous token isn't a number or a close bracket
        else if token.token == .OPER_SUBTRACT && index != 0{
            //Makes sure that the number is supposed to be negative
            if tokenisedList[index - 1].token != .ID && tokenisedList[index - 1].token != .CLOSE_BRACKET{
                digits = digits + "-"

                //Sets the pointer to the start of the number, if it isn't already
                if pointer == -1{pointer = index}
                //Removes the token from the tokenisedList
                tokenisedList.remove(at: index)
                //Accounts for removing the token
                index -= 1
            }
        }else{
            //Adds the number to the tokenisedList at the correct index
            if pointer != -1{tokenisedList.insert(Token(token: Tokens.ID, operand: VariableContainer.addValue(Float(digits)!)), at: pointer)}

            digits = ""
            //Sets the pointer to the default index
            pointer = -1
        }
        index += 1
    }
    //Adds the last number if it exists
    if digits != ""{tokenisedList.insert(Token(token: Tokens.ID, operand: VariableContainer.addValue(Float(digits)!)), at: pointer)}
}

//Parses a single level into a node tree
//Arguments:    -A list of tokens   -Token
//Return:       -A Node             -Node
func parseLevel(_levelTokens:[Token]) -> Node{
    var levelTokens = _levelTokens
    //Stores an array of possible operations in search order
    let operations:[Tokens] = [.OPER_SUBTRACT, .OPER_ADD, .OPER_MULTIPLY, .OPER_DIVIDE, .OPER_POWER, .FUNC_SIN, .FUNC_COS, .FUNC_TAN, .ID]
    //Stores a pointer into the array that is currently being searched
    var pointer = 0
    //Stores the bracket level, i.e. how many brackets are open
    var bracketLevel = 0
    //Stops if the pointer reaches -1
    while pointer != -1{
        //Reverses through the tokens
        for i in 0..<levelTokens.count{
            let index = levelTokens.count - i
            let token = levelTokens[index - 1]
            //If the token is a close bracket, it adds one to the bracketLevel, 
            //If the token is an open bracket, it takes one from the bracketLevel, this symbolises exiting the bracket
            bracketLevel = (token.token == .CLOSE_BRACKET) ? bracketLevel + 1 : (token.token == .OPEN_BRACKET) ? bracketLevel - 1 : bracketLevel
            //Checks if the token is equal to the currently searched for operation and that it is on the outer most bracket level
            if token.token == operations[pointer] && bracketLevel == 0{
                //Creates a node with the token and adds the children to it
                var node = Node(token: token)
                //Checks if the pointer is searching for an ID
                if operations[pointer] == .ID{return node}
                if operations[pointer] == .FUNC_SIN || operations[pointer] == .FUNC_COS || operations[pointer] == .FUNC_TAN{
                    node.children = [parseLevel(_levelTokens: Array(levelTokens[index...]))]
                    return node
                }
                //Parses the left side of the operator and gets a node tree
                let childNode_0 = parseLevel(_levelTokens: Array(levelTokens[..<(index - 1)]))
                //Parses the right side of the operator and gets a node tree
                let childNode_1 = parseLevel(_levelTokens: Array(levelTokens[index...]))
                node.children = [childNode_0, childNode_1]
                return node
            }
        }
        pointer += 1
        //Stops if the pointer is at the length of operations
        if pointer == operations.count{
            // If the pass had no result, it deletes the surrounding brackets (if they exist)
            if levelTokens[0].token == .OPEN_BRACKET && levelTokens[levelTokens.count - 1].token == .CLOSE_BRACKET{
                levelTokens.remove(at: 0)
                levelTokens.remove(at: levelTokens.count - 1)
                pointer = 0
            }else{
                break
            }
        }
    }
    return Node(token: Token(token: .ID, operand: 0))
}


let arg = CommandLine.arguments[1]
if arg != ""{
    //Creates a node tree from the given calculation
    lexicalAnalysis(arg)
    let nodeTree = parseLevel(_levelTokens: tokenisedList)
    
    //Prints the result of the calculation
    print(nodeTree.getValue())
}else{
    print("Please add a calculation enclosed in quotation marks")
}