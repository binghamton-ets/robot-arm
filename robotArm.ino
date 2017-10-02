#include <Servo.h>
#include <EEPROM.h>

// Pre-compile Constants
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

#define DEFAULT_SPEED 3
#define MIN_SPEED 1
#define MAX_SPEED 20

// Custom Type Definitions
typedef struct _range {
  int min;
  int max;
} Range;

typedef struct _motorRanges {
  Range rotation;
  Range shoulder;
  Range elbow;
  Range hand;
} MotorRanges;

// Global State
Servo rotationServo;
Servo shoulderServo;
Servo elbowServo;
Servo handServo;
bool motorsAreEngaged = false;
MotorRanges motorRanges = {
  .rotation = { .min = 0, .max = 180 },
  .shoulder = { .min = 0, .max = 180 },
  .elbow = { .min = 0, .max = 180 },
  .hand = { .min = 0, .max = 180 },
};
int speed = DEFAULT_SPEED;

void setup() {
  // Attach the servos to the I/O port
  engage();

  // Open serial communications with the host
  Serial.begin(9600);

  // Communicate that the device is ready
  reportSuccess();
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
  Serial.println("STATUS[OK]");
}

void reportMessage(char * src, char * message) {
  Serial.print("INFO[");
  Serial.print(src);
  Serial.print("] ");
  Serial.println(message);
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

  if (strcmp(argv[0], "SET_ANGLE") == 0) {
    return setMotorAngle(argc, argv);
  } else if (strcmp(argv[0], "SET_PERC") == 0) {
    return setMotorPercentage(argc, argv);
  } else if (strcmp(argv[0], "ENGAGE") == 0) {
    return engage();
  } else if (strcmp(argv[0], "DISENGAGE") == 0) {
    return disengage();
  } else if (strcmp(argv[0], "MAX_ANGLE") == 0) {
    return setMaxAngle(argc, argv);
  } else if (strcmp(argv[0], "MIN_ANGLE") == 0) {
    return setMinAngle(argc, argv);
  } else if (strcmp(argv[0], "GET_ANGLE") == 0) {
    return getAngle(argc, argv);
  } else if (strcmp(argv[0], "SET_SPEED") == 0) {
    return setSpeed(argc, argv);
  }

  reportError(ERROR_UNKNOWN_CMD, "Unknown command");
  return false;
}

bool setMotorAngle(int argc, char ** argv) {
  if (argc != 3) {
    reportError(ERROR_MALFORMED, "SET_ANGLE expected 2 arguments");
    return false;
  }

  bool foundMotor = false;
  int min, max;
  Servo targetMotor;
  if (strcmp(argv[1], "ROTATION") == 0) {
    foundMotor = true;
    min = motorRanges.rotation.min;
    max = motorRanges.rotation.max;
    targetMotor = rotationServo;
  } else if (strcmp(argv[1], "SHOULDER") == 0) {
    foundMotor = true;
    min = motorRanges.shoulder.min;
    max = motorRanges.shoulder.max;
    targetMotor = shoulderServo;
  } else if (strcmp(argv[1], "ELBOW") == 0) {
    foundMotor = true;
    min = motorRanges.elbow.min;
    max = motorRanges.elbow.max;
    targetMotor = elbowServo;
  } else if (strcmp(argv[1], "HAND") == 0) {
    foundMotor = true;
    min = motorRanges.hand.min;
    max = motorRanges.hand.max;
    targetMotor = handServo;
  }

  if (foundMotor) {
    int targetPosition = constrain(atoi(argv[2]), min, max);
    sweepMotorTo(targetMotor, targetPosition);
    return true;
  }

  reportError(ERROR_UNKNOWN_MOTOR, "Unknown motor");
  return false;
}

bool setMotorPercentage(int argc, char ** argv) {
  if (argc != 3) {
    reportError(ERROR_MALFORMED, "SET_PERC expected 2 arguments");
    return false;
  }

  bool foundMotor = false;
  int min, max;
  Servo targetMotor;
  if (strcmp(argv[1], "ROTATION") == 0) {
    foundMotor = true;
    min = motorRanges.rotation.min;
    max = motorRanges.rotation.max;
    targetMotor = rotationServo;
  } else if (strcmp(argv[1], "SHOULDER") == 0) {
    foundMotor = true;
    min = motorRanges.shoulder.min;
    max = motorRanges.shoulder.max;
    targetMotor = shoulderServo;
  } else if (strcmp(argv[1], "ELBOW") == 0) {
    foundMotor = true;
    min = motorRanges.elbow.min;
    max = motorRanges.elbow.max;
    targetMotor = elbowServo;
  } else if (strcmp(argv[1], "HAND") == 0) {
    foundMotor = true;
    min = motorRanges.hand.min;
    max = motorRanges.hand.max;
    targetMotor = handServo;
  }

  if (foundMotor) {
    int targetPosition = (((max - min) * atoi(argv[2])) + min) / 100;
    sweepMotorTo(targetMotor, targetPosition);
    return true;
  }

  reportError(ERROR_UNKNOWN_MOTOR, "Unknown motor");
  return false;
}

bool engage() {
  if (!motorsAreEngaged) {
    rotationServo.attach(5);
    shoulderServo.attach(6);
    elbowServo.attach(9);
    handServo.attach(10);
    motorsAreEngaged = true;
  }
  return true;
}

bool disengage() {
  if (motorsAreEngaged) {
    rotationServo.detach();
    shoulderServo.detach();
    elbowServo.detach();
    handServo.detach();
    motorsAreEngaged = false;
  }
  return true;
}

bool setMaxAngle(int argc, char ** argv) {
  if (argc != 3) {
    reportError(ERROR_MALFORMED, "MAX_ANGLE expected 2 arguments");
    return false;
  }

  int max = atoi(argv[2]);
  if (strcmp(argv[1], "ROTATION") == 0) {
    motorRanges.rotation.max = max;
    return true;
  } else if (strcmp(argv[1], "SHOULDER") == 0) {
    motorRanges.shoulder.max = max;
    return true;
  } else if (strcmp(argv[1], "ELBOW") == 0) {
    motorRanges.elbow.max = max;
    return true;
  } else if (strcmp(argv[1], "HAND") == 0) {
    motorRanges.hand.max = max;
    return true;
  }

  reportError(ERROR_UNKNOWN_MOTOR, "Unknown motor");
  return false;
}

bool setMinAngle(int argc, char ** argv) {
  if (argc != 3) {
    reportError(ERROR_MALFORMED, "MIN_ANGLE expected 2 arguments");
    return false;
  }

  int min = atoi(argv[2]);
  if (strcmp(argv[1], "ROTATION") == 0) {
    motorRanges.rotation.min = min;
    return true;
  } else if (strcmp(argv[1], "SHOULDER") == 0) {
    motorRanges.shoulder.min = min;
    return true;
  } else if (strcmp(argv[1], "ELBOW") == 0) {
    motorRanges.elbow.min = min;
    return true;
  } else if (strcmp(argv[1], "HAND") == 0) {
    motorRanges.hand.min = min;
    return true;
  }

  reportError(ERROR_UNKNOWN_MOTOR, "Unknown motor");
  return false;
}

bool setSpeed(int argc, char ** argv) {
  if (argc != 2) {
    reportError(ERROR_MALFORMED, "SET_SPEED expected 1 arguments");
    return false;
  }

  speed = atoi(argv[1]);
  return true;
}

bool getAngle(int argc, char ** argv) {
  if (argc != 2) {
    reportError(ERROR_MALFORMED, "GET_ANGLE expected 1 argument");
    return false;
  }

  Servo targetMotor;
  bool foundMotor = false;
  if (strcmp(argv[1], "ROTATION") == 0) {
    targetMotor = rotationServo;
    foundMotor = true;
  } else if (strcmp(argv[1], "SHOULDER") == 0) {
    targetMotor = rotationServo;
    foundMotor = true;
  } else if (strcmp(argv[1], "ELBOW") == 0) {
    targetMotor = rotationServo;
    foundMotor = true;
  } else if (strcmp(argv[1], "HAND") == 0) {
    targetMotor = rotationServo;
    foundMotor = true;
  }

  if (foundMotor) {
    char * angle = (char *)malloc(sizeof(char) * 4);
    itoa(targetMotor.read(), angle, 4);
    reportMessage("GET_ANGLE", angle);
    free(angle);
    return true;
  }

  reportError(ERROR_UNKNOWN_MOTOR, "Unknown motor");
  return false;
}

bool sweepMotorTo(Servo motor, int targetAngle) {
  int initialAngle = motor.read();
  int stepAmount = (targetAngle > initialAngle) ? 1 : -1;
  for (int i = 0; i < abs(targetAngle - initialAngle); i++) {
    motor.write(initialAngle + (i * stepAmount));
    delay(constrain(speed, MIN_SPEED, MAX_SPEED));
  }
  return true;
}
