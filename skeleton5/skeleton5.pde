import processing.opengl.*;
import SimpleOpenNI.*;
SimpleOpenNI kinect;
import saito.objloader.*;

OBJModel model;

void setup(){
	size(1028, 768, OPENGL);

	model = new OBJModel(this,"kinect.obj","relative",TRIANGLES);
	model.translateToCenter();

	kinect = new SimpleOpenNI(this);
	kinect.enableDepth();
	kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
	kinect.setMirror(true);

	fill(255, 0, 0);
}

PImage colorImage;
boolean gotImage;

void draw(){
	kinect.update();
	background(0);

	translate(width/2, height/2, 0);
	rotateX(radians(180));

	scale(0.9);

	IntVector userList = new IntVector();
	kinect.getUsers(userList);

	if(userList.size()> 0){
		int userId = userList.get(0);

		if (kinect.isTrackingSkeleton(userId)){
			PVector position = new PVector();
			kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,position);

			PMatrix3D orientation = new PMatrix3D();
			float confidence = kinect.getJointOrientationSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,orientation);

			println(confidence);
			drawSkeleton(userId);

			pushMatrix();
				translate(position.x, position.y,position.z);

				applyMatrix(orientation);
				model.draw();

			popMatrix();

		}
	}
}
void drawSkeleton(int userId){
	drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
	drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
	drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
	drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
	drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
	drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
	drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
	drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
	drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
	drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
	drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
	drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
	drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
	drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
	drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
	drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
}

void drawLimb(int userId,int jointType1, int jointType2){
	PVector jointPos1  =  new PVector();
	PVector jointPos2  =  new PVector();
	float confidence;

	confidence = kinect.getJointPositionSkeleton(userId,jointType1,jointPos1);
	confidence += kinect.getJointPositionSkeleton(userId,jointType2,jointPos2);

	stroke(100);
	strokeWeight(5);

	if (confidence>1){
		line(jointPos1.x, jointPos1.y, jointPos1.z, jointPos2.x, jointPos2.y, jointPos2.z);
	}
}

// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startPoseDetection("Psi", userId);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } 
  else { 
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
}	






