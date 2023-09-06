import random
import string

message = "TEST STRING"

code = []


baseList = []

def Scramble_Letters(message,alphabet):
    scrambledLetters = []
    for character in message:
        if isinstance(character, str):
            character = ord(character)
        #correction for not using the entire ASCII table
        newCharacter = character-37 
        scrambledLetters.append(alphabet[newCharacter])

    return scrambledLetters
def Encode_Message(alphabet):
    messageASCII = []
    message = input("Welcome Agent,please enter the message you need to encode.\n")
    originalAlphabet = alphabet
    for char in message:
        messageASCII.append(ord(char))
    totalPasses = random.randint(1,10)
    # scramble the alphabet
    for i in range(totalPasses):
        scrambledAlphabet = []
        offset = random.randint(0,36)
        scrambledAlphabet = alphabet[offset:] + alphabet[:offset]
        messageASCII = Scramble_Letters(messageASCII,scrambledAlphabet)
        print(messageASCII)



def Decode_Message():

    message = input("Welcome Agent,please enter the message you need to decode.\n")

    


if __name__ =='__main__': 
    for i in range(33,123):
        baseList.append(chr(i))
    option = input('Hello agent, do you need to: \n1)encode\n2)decode\n3)exit\n')
    if option =="1":
        Encode_Message(baseList)
    elif option == "2":
        Decode_Message()
    elif option =="3":
        exit()



# print(baseList)
# firstPass = 3
# secondList = baseList[firstPass:] + baseList[:firstPass]
# print(secondList)


