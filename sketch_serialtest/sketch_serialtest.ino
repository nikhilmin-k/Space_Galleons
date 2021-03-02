const int buttonPin = 2;
const int ledPin = 32;

int buttonState = 0;

void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}
void loop() {
  //digitalWrite(ledPin, HIGH);
  if (buttonPin == HIGH){ 
    digitalWrite(ledPin, HIGH); //digitalwrite occurs, but only after the button is released, don't know why
    //Serial.println("Hello from Arduino!");
    delay(1000);
  }
  if (buttonPin == LOW){
    digitalWrite(ledPin, LOW); 
  }
  
  //Serial.println(buttonState);
}
