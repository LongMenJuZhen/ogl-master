#ifndef CONTROLS_HPP
#define CONTROLS_HPP

void computeMatricesFromInputs();
glm::mat4 getViewMatrix();
glm::mat4 getProjectionMatrix();
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);
void fractalGetInput(GLdouble &xL, GLdouble &yD, GLdouble  &xR, GLdouble &yT, int &winW, int &winH);
#endif