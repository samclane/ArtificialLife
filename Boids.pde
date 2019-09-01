import java.io.*;

class Boid {
  
  PVector position;
  PVector velocity;
  PVector acceleration;
  float detectionRadius;
  float fov;
  ArrayList<Boid> swarm;
  ArrayList<PVector> constantForces;


  Boid(PVector p, PVector v, float r, float f, ArrayList<Boid> s) {
    position = p;
    velocity = v;
    acceleration = new PVector(0, 0);
    detectionRadius = r;
    fov = f;
    swarm = s;
    constantForces = new ArrayList<PVector>();
  }

  void draw() {
    pushMatrix();
    {
      translate(position.x, position.y);
      rotate(velocity.heading());
      fill(#7A9B76);
      triangle(bodySize*2, 0, -bodySize*2, bodySize, -bodySize*2, -bodySize);
    }
    popMatrix();
  }


  void update() {
    velocity = velocity.add(acceleration);
    position = position.add(velocity);

    // Mirror edges of world (Pac-Man style)
    if (position.x > width)
      position.x = 0;
    if (position.y > height)
      position.y = 0;
    if (position.x < 0)
      position.x = width;
    if (position.y < 0)
      position.y = height;

    // Swarming behavior
    for (Boid b : swarm) {
      if (inRange(b.position)) {
        acceleration.add(b.velocity);
        if (position.dist(b.position) <= bodySize * 4) {
          acceleration.sub(PVector.sub(b.position, position).rotate(radians(90)));
        }
      }
    }

    for (PVector force : constantForces) {
      acceleration.add(force);
    }

    acceleration.limit(maxAcceleration);
    velocity.limit(maxVelocity);
  }

  boolean inRange(PVector target) {
    return (position.dist(target) < detectionRadius && abs(PVector.angleBetween(position, target)) <= fov);
  }

  void update(PVector target) {
    if (inRange(target)) { 
      seekTarget(target);
    }
    this.update();
  }

  void update(ArrayList<PVector> targets) {
    for (PVector t : targets) {
      if (inRange(t)) {
        seekTarget(t);
      }
    }
    this.update();
  }

  void addConstantForce(PVector force) {
    constantForces.add(force);
  }

  void seekTarget(PVector target) {
    acceleration.add(PVector.sub(target, position).mult(1 / target.dist(position)));
  }
}

ArrayList<Boid> swarm = new ArrayList<Boid>();
ArrayList<PVector> magnets = new ArrayList<PVector>();
final  float bodySize = 5;
final int numBoids = 300;
final int numMags = 3;
final float senseRange = 100;
final float senseAngle = .99 * PI;
final PVector gravity = new PVector(0, 1e-3);
final float maxAcceleration = 1;
final float maxVelocity = 5;

void setup() {
  fullScreen();
  //size(800, 600);
  for (int i = 0; i < numBoids; i++) {
    Boid b = new Boid(new PVector(random(width), random(height)), PVector.random2D(), senseRange, senseAngle, swarm);
    swarm.add(b);
    b.addConstantForce(gravity);
  }
  for (int i = 0; i < numMags; i++) {
    PVector mag = new PVector(random(width), random(height));
    magnets.add(mag);
  }
}

void draw() {
  background(#090302);
  PVector mouse = new PVector(mouseX, mouseY);
  magnets.add(mouse);
  for (Boid b : swarm) {
    b.draw();
    b.update(magnets);
  }
  fill(255);
  for (PVector m : magnets) {
    circle(m.x, m.y, 15);
  }
  magnets.remove(mouse);
}
