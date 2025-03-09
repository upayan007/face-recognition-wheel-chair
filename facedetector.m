
       
%cleaning up
clc;
close all;
clear all;
%initialize serial communiction btw ide and matlab
arduino_port='COM6';
baud_rate=9600;
ser=serialport(arduino_port,baud_rate );
pause(2);
%hardware and bluetooth setup
hardware_connected=0;
if (hardware_connected==1)
delete (instrfind); %delete connected ports
s=connect_bluetooth;
end
%setup
% create the face detector object
faceDetector=vision.CascadeObjectDetector();
%create point tracker object
pointTracker=vision.PointTracker('MaxBidirectionalError',2);
%create webcam object
cam=webcam();
%capture one frame to get its size
videoFrame=snapshot(cam);
frameSize=size(videoFrame);
%displaying 1st shot and the detected face
FirstPose=videoFrame;
bbox1=step(faceDetector , FirstPose);
FirstShow=insertShape(FirstPose,'Rectangle',bbox1);
figure;
imshow(FirstShow);
title('Detected Face');
%Create the video player
videoPlayer=vision.VideoPlayer('Position',[100 100 [frameSize(2), frameSize(1)]+30]);
%detection and tracking
runLoop=true;
numPts=0;
frameCount=0;
while runLoop && frameCount < 400
    
   %get the next frame
   videoFrame=snapshot(cam);
   videoFrameGray=rgb2gray(videoFrame);
   frameCount=frameCount+1;
   
   if numPts<10
       %detection mode
       bbox=faceDetector.step(videoFrameGray);
       
       if ~isempty(bbox)
           %find corner points inside the detected region
           points=detectMinEigenFeatures(videoFrameGray,'ROI',bbox(1,:));
           
           %re-initialize the point tracker
           xyPoints=points.Location;
           numPts=size(xyPoints,1);
           release(pointTracker);
           initialize(pointTracker,xyPoints,videoFrameGray);
           
           % save a copy of the points
           oldPoints=xyPoints;
           
           %convert the reactangle represented as [x,y,w,h]into a 
           %M by 2 matrix of [x,y] co-ordinates of the 4 corners. 
           %this is needed to be able to transform the bounding box to
           %display the orientation of the face
           bboxPoints=bbox2points(bbox(1,:));
           
           %convert the box corners into the [x1,y1,x2,y2,,x3,y3,x4,y4]
           %format required by insert shape
           bboxPolygon=reshape(bboxPoints',1,[]);
           
           %display a bounding box around the detected face
           videoFrame=insertShape(videoFrame,'Polygon',bboxPolygon,'LineWidth',3);
           
           %display detected corners
           videoFrame=insertMarker(videoFrame,xyPoints,'+','color','white');
       end
   else
       %tracking mode
       if frameCount==2
           ref=xyPoints;
       end
       %disp('you can track your head and hardware movement below')
       [xyPoints,isFound]=step(pointTracker,videoFrameGray);
       visiblePoints=xyPoints(isFound, :);
       oldInliers=oldPoints(isFound, :);
       
       numPts=size(visiblePoints,1);
       
       if numPts>=10
           %estimate geometric transformation btw old points
           %and add the new points
           [xform,oldInliers,visiblePoints]=estimateGeometricTransform(...
               oldInliers,visiblePoints,'similarity','MaxDistance',4);
           
           %apply the transformation of bounding box
           bboxPoints=transformPointsForward(xform,bboxPoints);
           
           %convert the box corners into the [x1,y1,x2,y2,x3,y3,x4,y4]
           %format required by insert shape
           bboxPolygon=reshape(bboxPoints',1,[]);
           
           %display a bounding box around the face being tracked
           videoFrame=insertShape(videoFrame,'Polygon',bboxPolygon,'LineWidth',3);
           
           %display tracked points
           videoFrame=insertMarker(videoFrame,visiblePoints,'+','color','white');
           
           %reset the points
           oldPoints=visiblePoints;
           setPoints(pointTracker,oldPoints);
       end
       
       %getting face movement direction using geometric
       %transformation using frames
       %disp('face turning towards:)
       for frameCount=0:400:100
           if(mean2(visiblePoints) - mean2(ref))<-20
               disp('Right');
               writeline(ser,"R");
               
               %bluetooth data transfer if hardware connected
               if(hardware_connected==1)
                   writeline(ser,"R");
                   disp('Data for Right SENT');
               end
           elseif (mean2(visiblePoints)- mean2(ref))>25 
               disp('Left');
               writeline(ser,"L");
               %bluetooth data transfer if hardware connected
               if (hardware_connected==1)
               writeline(ser,"L");
               disp('data for left signal');
               end
           else
               disp('Forward');
               writeline(ser,"F");
               %bluetooth data if hardware connected
               if(hardware_connected==1)
                   fprintf(s,'1');
                   disp('data for straight sent');
               end
           end
           %disp(mean2(variablePoints)-mean2(ref));
       end
   end
end
   %cleanup
   clear ser;
   clear cam
   
   release(videoPlayer);
   release(pointTracker);
   release(faceDetector); 










