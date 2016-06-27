% go through our fruits directory image by image
DATA_DIR = 'fruits\';
fruit_dir = dir(DATA_DIR);
threeRGB = fopen('3rgb.txt','wt');
nineRGB = fopen('9rgb.txt','wt');
hsv = fopen('hsv.txt','wt');
 
for index = fruit_dir'
    if ~(strcmp(index.name,'.') || (strcmp(index.name,'..')))
        fileName = strcat(DATA_DIR, index.name);
        A = imread(fileName);
        
        [height,width, color] = size(A);
        [value1,value2] = size(size(A));
        
        % if image has RGB channels
        if(value2 == 3)  
            hsvImage = rgb2hsv(A);
            % determines desired output for NN based on fruit image
            if ~isempty(strfind(fileName,'watermelon'))
                output = [1 0 0 0 0 0 0 0];
            elseif ~isempty(strfind(fileName,'slice'))
                output = [0 1 0 0 0 0 0 0];
            elseif ~isempty(strfind(fileName,'banana'))
                output = [0 0 1 0 0 0 0 0];
            elseif ~isempty(strfind(fileName,'apple'))
                output = [0 0 0 1 0 0 0 0];
            elseif (~isempty(strfind(fileName,'_apple_'))) && (isempty(strfind(fileName,'apple')))
                output = [0 0 0 0 1 0 0 0];
            elseif ~isempty(strfind(fileName,'orange'))
                output = [0 0 0 0 0 1 0 0];
            elseif ~isempty(strfind(fileName,'tomato'))
                output = [0 0 0 0 0 0 1 0];
            elseif ~isempty(strfind(fileName,'mango'))
                output = [0 0 0 0 0 0 0 1];
            end
                         
            redSum = 0; 
            greenSum = 0;
            blueSum = 0;
            pixels = 0;
               
            % histogram technique with channel ranges
            redRanges = ones(1,6);
            greenRanges = ones(1,6);
            blueRanges= ones(1,6);
            
            %hsv computation
            hsvBuckets = 25;
            
            hsvRanges = ones(2,hsvBuckets);
            hsvDivisor = 1/hsvBuckets;
            
            % iterating pixel by pixel and summing each channel
            for row=1:height
                for column=1:width  
                    % if white pixel, ignore (background)
                    if ~( (A(row,column,1)> 200 && A(row,column,2)> 200 && A(row,column,3)> 200) || (A(row,column,1)<35 && A(row,column,2)<35 && A(row,column,3)< 35))
                        % simple 3 rgb channels
                        pixels = pixels + 1;
                        redSum = redSum + double(A(row,column,1));
                        greenSum = greenSum + double(A(row,column,2));
                        blueSum = blueSum + double(A(row,column,3));
                        
                        %red ranges
                        if((A(row,column,1)) <= 67)
                            redRanges(1,1) = redRanges(1,1) + double(A(row,column,1));
                            redRanges(1,4) = redRanges(1,4) + 1;
                        elseif((A(row,column,1)) > 67 && (A(row,column,1)) <= 134)
                            redRanges(1,2) = redRanges(1,2) + double(A(row,column,1));
                            redRanges(1,5) = redRanges(1,5) + 1;
                        elseif((A(row,column,1)) > 134)
                            redRanges(1,3) = redRanges(1,3) + double(A(row,column,1));                          
                            redRanges(1,6) = redRanges(1,6) + 1;
                        end
                        
                        %green ranges
                        if(A(row,column,2) <= 67)
                            greenRanges(1,1) = greenRanges(1,1) + double(A(row,column,2));
                            greenRanges(1,4) = greenRanges(1,4) + 1;
                        elseif((A(row,column,2)) > 67 && (A(row,column,2)) <= 134)
                            greenRanges(1,2) = greenRanges(1,2) + double(A(row,column,2));
                            greenRanges(1,5) = greenRanges(1,5) + 1;
                        elseif( (A(row,column,2)) > 134)
                            greenRanges(1,3) = greenRanges(1,3) + double(A(row,column,2));                          
                            greenRanges(1,6) = greenRanges(1,6) + 1;
                        end
                        
                        %blue ranges
                        if(A(row,column,3) <= 67)
                            blueRanges(1,1) = blueRanges(1,1) + double(A(row,column,3));
                            blueRanges(1,4) = blueRanges(1,4) + 1;
                        elseif((A(row,column,2)) > 67 && (A(row,column,2)) <= 134)
                            blueRanges(1,2) = blueRanges(1,2) + double(A(row,column,3));
                            blueRanges(1,5) = blueRanges(1,5) + 1;
                        elseif( (A(row,column,2)) > 134)
                            blueRanges(1,3) = blueRanges(1,3) + double(A(row,column,3));                          
                            blueRanges(1,6) = blueRanges(1,6) + 1;
                        end
                        
                        %hsv technique
                        hsvIndex = floor(double(hsvImage(row,column,1))/hsvDivisor) + 1;
                        hueValue = double(hsvImage(row,column,1));
                        hsvRanges(1, hsvIndex) = hsvRanges(1,hsvIndex) + hueValue;
                        hsvRanges(2, hsvIndex) = hsvRanges(2, hsvIndex) + 1;
                    end
                end
            end
            % the channel sums will be divided by the total eligible pixels
            % and this will become the input to the NN
            redSum = double(redSum)/double(pixels);
            greenSum = double(greenSum)/double(pixels);
            blueSum = double(blueSum)/double(pixels);
            
       
            redRanges(1,1) = double(redRanges(1,1))/double(redRanges(1,4));
            redRanges(1,2) = double(redRanges(1,2))/double(redRanges(1,5));
            redRanges(1,3) = double(redRanges(1,3))/double(redRanges(1,6));
           
            greenRanges(1,1) = double(greenRanges(1,1))/double(greenRanges(1,4));
            greenRanges(1,2) = double(greenRanges(1,2))/double(greenRanges(1,5));
            greenRanges(1,3) = double(greenRanges(1,3))/double(greenRanges(1,6));
            
            blueRanges(1,1) = double(blueRanges(1,1))/double(blueRanges(1,4));
            blueRanges(1,2) = double(blueRanges(1,2))/double(blueRanges(1,5));
            blueRanges(1,3) = double(blueRanges(1,3))/double(blueRanges(1,6));
            
            hsvRanges(1,:) = hsvRanges(1,:) ./ hsvRanges(2,:);
                        
                % file printing input/output pair for 3rgb
                fprintf(threeRGB, '%.3f ', redSum);
                fprintf(threeRGB, '%.3f ', blueSum);
                fprintf(threeRGB, '%.3f ', greenSum);
                fprintf(threeRGB, '%d ', output);
                fprintf(threeRGB,'\n');

                % file printing input/output pair for 9rgb
                [x,y] = size(redRanges);
                for elemental=1:y-3
                    fprintf(nineRGB, ' %.3f ', redRanges(1,elemental));
                end
                for elemental=1:y-3
                    fprintf(nineRGB, ' %.3f ', greenRanges(1,elemental));
                end
                for elemental=1:y-3
                    fprintf(nineRGB, ' %.3f ', blueRanges(1,elemental));
                end
                fprintf(nineRGB, '%d ', output);
                fprintf(nineRGB,'\n');

                % file printing input/output pair for hsv
                fprintf(hsv, '%.3f ', hsvRanges(1,:));
                fprintf(hsv, '%d ', output);
                fprintf(hsv,'\n');
        end
    end
end
fclose(threeRGB);
fclose(nineRGB);
fclose(hsv);

done