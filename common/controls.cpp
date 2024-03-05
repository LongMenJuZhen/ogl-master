// Include GLFW
#include <GLFW/glfw3.h>
extern GLFWwindow* window; /* The "extern" keyword here is to access
						   the variable "window" declared in tutorialXXX.cpp. 
						 This is a hack to keep the tutorials simple. 
						 Please avoid this.*/
// Include GLM
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
using namespace glm;

#include "controls.hpp"
#include <iostream>
#include "stdio.h"

glm::mat4 ViewMatrix;
glm::mat4 ProjectionMatrix;

glm::mat4 getViewMatrix()		{	return ViewMatrix;		}
glm::mat4 getProjectionMatrix()	{	return ProjectionMatrix;}

// Initial horizontal angle : toward -Z
float horizontalAngle = 3.14f;
// Initial vertical angle : none
float verticalAngle = 0.0f;
// Initial Field of View
float initialFoV = 45.0f;

float speed = 3.0f; // 3 units / second
float mouseSpeed = 0.005f;

double scrollYoff = 0.0;
double gYoffset = 0;
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
	// here your response to cursor scrolling ...
	// yoffset > 0 means you scrolled up, i think
	//printf("%0.1f\n", xoffset);
	scrollYoff+=yoffset;
	gYoffset = yoffset;
}

#define  UIMODE_ORIGINAL

#ifdef UIMODE_ORIGINAL		// the original UI
// Initial position : on +Z
glm::vec3 position = glm::vec3( 0, 0, 5 ); 

void computeMatricesFromInputs(){

	// glfwGetTime is called only once, the first time this function is called
	static double lastTime = glfwGetTime();

	// Compute time difference between current and last frame
	double currentTime = glfwGetTime();
	float deltaTime = float(currentTime - lastTime);

	// Get mouse position
	double xpos, ypos;
	glfwGetCursorPos(window, &xpos, &ypos);

	// Reset mouse position for next frame
	glfwSetCursorPos(window, 1024/2, 768/2);

	// Compute new orientation
	horizontalAngle += mouseSpeed * float(1024/2 - xpos );
	verticalAngle   += mouseSpeed * float( 768/2 - ypos );

	// Direction : Spherical coordinates to Cartesian coordinates conversion
	glm::vec3 direction(
		cos(verticalAngle) * sin(horizontalAngle), 
		sin(verticalAngle),
		cos(verticalAngle) * cos(horizontalAngle)
		);

	// Right vector
	glm::vec3 right = glm::vec3(
		sin(horizontalAngle - 3.14f/2.0f), 
		0,
		cos(horizontalAngle - 3.14f/2.0f)
		);

	// Up vector
	glm::vec3 up = glm::cross( right, direction );

	// Move forward
	if (glfwGetKey( window, GLFW_KEY_UP ) == GLFW_PRESS){
		position += direction * deltaTime * speed;
	}
	// Move backward
	if (glfwGetKey( window, GLFW_KEY_DOWN ) == GLFW_PRESS){
		position -= direction * deltaTime * speed;
	}
	// Strafe right
	if (glfwGetKey( window, GLFW_KEY_RIGHT ) == GLFW_PRESS){
		position += right * deltaTime * speed;
	}
	// Strafe left
	if (glfwGetKey( window, GLFW_KEY_LEFT ) == GLFW_PRESS){
		position -= right * deltaTime * speed;
	}

	glfwSetScrollCallback(window, scroll_callback);
	//float FoV = initialFoV;// - 5 * glfwGetMouseWheel(); // Now GLFW 3 requires setting up a callback for this. It's a bit too complicated for this beginner's tutorial, so it's disabled instead.
	float FoV = initialFoV - scrollYoff;

	// Projection matrix : 45?Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
	ProjectionMatrix = glm::perspective(glm::radians(FoV), 4.0f / 3.0f, 0.1f, 100.0f);
	// Camera matrix
	ViewMatrix       = glm::lookAt(
		position,           // Camera is here
		position+direction, // and looks here : at the same position, plus "direction"
		up                  // Head is up (set to 0,-1,0 to look upside-down)
		);

	// For the next frame, the "last time" will be "now"
	lastTime = currentTime;
}


#else //my modification to UI
// Initial position : on the origin
glm::vec3 oC = glm::vec3( 0, 0, 0 ); 
float radius = 5;
void computeMatricesFromInputs(){

	// glfwGetTime is called only once, the first time this function is called
	static double lastTime = glfwGetTime();

	// Compute time difference between current and last frame
	double currentTime = glfwGetTime();
	float deltaTime = float(currentTime - lastTime);

	// Get mouse position
	double xpos, ypos;
	glfwGetCursorPos(window, &xpos, &ypos);

	// Reset mouse position for next frame
	glfwSetCursorPos(window, 1024/2, 768/2);

	// Compute new orientation
	horizontalAngle += mouseSpeed * float(1024/2 - xpos );
	verticalAngle   += mouseSpeed * float( 768/2 - ypos );

	// Direction : Spherical coordinates to Cartesian coordinates conversion
	glm::vec3 direction(
		cos(verticalAngle) * sin(horizontalAngle), 
		sin(verticalAngle),
		cos(verticalAngle) * cos(horizontalAngle)
		);

	// Right vector
	glm::vec3 right = glm::vec3(
		sin(horizontalAngle - 3.14f/2.0f), 
		0,
		cos(horizontalAngle - 3.14f/2.0f)
		);

	// Up vector
	glm::vec3 up = glm::cross( right, direction );

	// 	glm::vec3 rotateAx(1,1,1);
	// 	glm::mat4 rm;
	// 	glm::rotate(rm,90,rotateAx);

	// Move forward
	if (glfwGetKey( window, GLFW_KEY_UP ) == GLFW_PRESS)
		radius+=0.1;
	// Move backward
	if (glfwGetKey( window, GLFW_KEY_DOWN ) == GLFW_PRESS)
		radius-=0.1;
	// Strafe right
	if (glfwGetKey( window, GLFW_KEY_RIGHT ) == GLFW_PRESS){
	}
	// Strafe left
	if (glfwGetKey( window, GLFW_KEY_LEFT ) == GLFW_PRESS){
	}

	glm::vec3 position = oC + radius*direction;

	glfwSetScrollCallback(window, scroll_callback);
	float FoV = initialFoV - scrollYoff;

	// Projection matrix : 45?Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
	ProjectionMatrix = glm::perspective(glm::radians(FoV), 4.0f / 3.0f, 0.1f, 100.0f);
	// Camera matrix
	ViewMatrix       = glm::lookAt(
		position,	// Camera is here
		oC,			// and looks here : at the same position, plus "direction"
		up          // Head is up (set to 0,-1,0 to look upside-down)
		);

	// For the next frame, the "last time" will be "now"
	lastTime = currentTime;
}
#endif

void fractalGetInput(GLdouble &xL, GLdouble &yD, GLdouble  &xR, GLdouble &yT, int &winW, int &winH)
{
	if(glfwGetMouseButton( window, GLFW_MOUSE_BUTTON_LEFT ) == GLFW_PRESS){
		double DX, DY;
		glfwGetCursorPos(window, &DX, &DY);
		if((DX<450 && DY<250) ) return;  //TWbar UI
	}

	static double lbtnDnPosX, lbtnDnPosY;

	if(glfwGetMouseButton( window, GLFW_MOUSE_BUTTON_MIDDLE ) == GLFW_PRESS ){
		double px, py;
		glfwGetCursorPos(window, &px, &py);
		if(lbtnDnPosX==-1){
			lbtnDnPosX = px;
			lbtnDnPosY = py;
		}
		else{
			double mx,my;
			mx = -(px - lbtnDnPosX)/winW *(xR-xL);
			my = (py - lbtnDnPosY)/winH *(yT-yD);
			xL+=mx; xR+=mx; yD+=my; yT+=my;
			lbtnDnPosX = px;
			lbtnDnPosY = py;
		}
	}
	else{
		lbtnDnPosX = -1;	
		lbtnDnPosY = -1;
	}

	float zoom = 1.0;

	if(glfwGetMouseButton( window, GLFW_MOUSE_BUTTON_LEFT ) == GLFW_PRESS ){
		gYoffset = 1;
	}
	if(glfwGetMouseButton( window, GLFW_MOUSE_BUTTON_RIGHT ) == GLFW_PRESS ){
		gYoffset = -1;
	}
	glfwSetScrollCallback(window, scroll_callback);
	if(gYoffset==0) return;

	zoom = 1.0+ gYoffset*0.1f;
	gYoffset = 0;

	// Get mouse position
	double xpos, ypos;
	glfwGetCursorPos(window, &xpos, &ypos);
	ypos = winH - ypos+1;
	// Reset mouse position for next frame
	//glfwSetCursorPos(window, 1024/2, 768/2);

	GLdouble px = xpos/float(winW) * (xR-xL) + xL; 
	GLdouble py = ypos/float(winH) * (yT-yD) + yD; 
	xL = (xL - px)/zoom + px, xR = (xR - px)/zoom + px;
	yD = (yD - py)/zoom + py, yT = (yT - py)/zoom + py;
}