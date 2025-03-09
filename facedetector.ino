#define ENA 9   // Enable pin for motor A
#define ENB 10  // Enable pin for motor B
#define IN1 6   // Motor A direction
#define IN2 7
#define IN3 4   // Motor B direction
#define IN4 5

void setup() {
  Serial.begin(9600); // Start serial communication

  pinMode(ENA, OUTPUT);
  pinMode(ENB, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  stopMotors(); // Ensure motors are stopped initially
}

void loop() {
  if (Serial.available() > 0) { // Check if data is received
    char command = Serial.read(); // Read command from MATLAB

    if (command == 'F') {   // Move Forward
      moveForward();
    }
    else if (command == 'L') {  // Turn Left
      turnLeft();
    }
    else if (command == 'R') {  // Turn Right
      turnRight();
    }
    else if (command == 'S') {  // Stop
      stopMotors();
    }
  }
}

void moveForward() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  analogWrite(ENA, 150);  // Adjust speed (0-255)
  analogWrite(ENB, 150);
}

void turnLeft() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  analogWrite(ENA, 100);  
  analogWrite(ENB, 100);
}

void turnRight() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  analogWrite(ENA, 100);
  analogWrite(ENB, 100);
}

void stopMotors() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  analogWrite(ENA, 0);
  analogWrite(ENB, 0);
}







     