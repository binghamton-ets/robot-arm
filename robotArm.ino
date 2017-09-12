#include <Servo.h>

Servo rotationServo;
Servo shoulderServo;
Servo elbowServo;
Servo handServo;

#define ST_1_DECODE_COMMAND 1
#define ST_2_DECODE_MOTOR 2
#define ST_3_DECODE_ANGLE 3
#define ST_4_WAIT 4
#define INSTRUCTION_WIDTH 128
#define INSTRUCTION_ARG_WIDTH INSTRUCTION_WIDTH / 4

#define ERROR_UNEXPECTED -1
#define ERROR_MALFORMED 0
#define ERROR_UNKNOWN_CMD 1
#define ERROR_UNKNOWN_MOTOR 2

void setup() {
  // Attach the servos to the I/O port
  rotationServo.attach(5);
  shoulderServo.attach(6);
  elbowServo.attach(9);
  handServo.attach(10);

  // Open serial communications with the host
  Serial.begin(9600);
}

void loop() {
  char * instruction = getNextInstruction();
  if (instruction) {
    // Decode the instruction
    int argc = countInstructionArgs(instruction);
    char ** argv = getInstructionArgs(instruction, argc);

    // Execute the instruction
    bool success = executeInstruction(argc, argv);
    if (success) reportSuccess();

    // Dispose of the instruction
    free(instruction);
    free(argv);
  }
}

void reportSuccess() {
  Serial.println("OK");
}

void reportError(int errorCode, char * errorMessage) {
  Serial.print("ERROR[");
  Serial.print(errorCode);
  Serial.print("] ");
  Serial.println(errorMessage);
}

char * getNextInstruction() {
  // Capture the next line in the serial buffer
  if (Serial.available() > 0) {
    char * instructionBuffer = (char *)malloc(sizeof(char) * INSTRUCTION_WIDTH);
    int currentChar;
    for (currentChar = 0; currentChar < INSTRUCTION_WIDTH - 1; currentChar++) {
      if (Serial.available() <= 0) {
        break;
      } else if (Serial.peek() == '\n') {
        Serial.read();
        break;
      }
      instructionBuffer[currentChar] = Serial.read();
      delay(10);
    }
    instructionBuffer[currentChar] = '\0';
    return instructionBuffer;
  }
  return NULL;
}

int countInstructionArgs(char * instruction) {
  // Count the amount of segments in the current instruction
  if (instruction[0] == '\0') return 0;
  int argc = 0;
  for (int i = 0; i < INSTRUCTION_WIDTH; i++) {
    if (instruction[i] == '\0') {
      argc++;
      break;
    } else if (instruction[i] == ' ') {
      argc++;
    }
  }
  return argc;
}

char ** getInstructionArgs(char * instruction, int argc) {
  if (argc == 0) {
    return NULL;
  }
  char ** argv = (char **)malloc(sizeof(char *) * argc);
  char delim[2] = " ";
  argv[0] = strtok(instruction, delim);
  for (int i = 1; i < argc; i++) {
    argv[i] = strtok(NULL, delim);
  }
  return argv;
}

bool executeInstruction(int argc, char ** argv) {
  if (argc == 0) {
    return false;
  }

  if (strcmp(argv[0], "MOVE") == 0) {
    return move(argc, argv);
  }

  reportError(ERROR_UNKNOWN_CMD, "Unknown command");
  return false;
}

bool move(int argc, char ** argv) {
  if (argc != 3) {
    reportError(ERROR_MALFORMED, "MOVE expected 2 arguments");
    return false;
  }

  if (strcmp(argv[1], "ROTATION") == 0) {
    int targetPosition = atoi(argv[2]);
    rotationServo.write(targetPosition);
    return true;
  } else if (strcmp(argv[1], "SHOULDER") == 0) {
    int targetPosition = atoi(argv[2]);
    shoulderServo.write(targetPosition);
    return true;
  } else if (strcmp(argv[1], "ELBOW") == 0) {
    int targetPosition = atoi(argv[2]);
    elbowServo.write(targetPosition);
    return true;
  } else if (strcmp(argv[1], "HAND") == 0) {
    int targetPosition = atoi(argv[2]);
    handServo.write(targetPosition);
    return true;
  }

  reportError(ERROR_UNKNOWN_MOTOR, "Unknown motor");
  return false;
}
