clear;
% go through our fruits directory image by image
DATA_DIR = 'fruits4\';
fruit_dir = dir(DATA_DIR);

hsvBuckets = 20;   

tBuckets = 25;

correct = 0;
total = 0;

prompt = '1 for RGB,2 for HSV, 3 for H, 4 for T, 5 for HT ';
userEnter = input(prompt);
confusionMatrix = zeros(7,7);
for index = fruit_dir'
    if ~(strcmp(index.name,'.') || (strcmp(index.name,'..')))
        fileName = strcat(DATA_DIR, index.name);
        T = imread(fileName);        
        
        [height,width, color] = size(T);
        [value1,value2] = size(size(T));
        
        if( height > 285  || width > 285)
            A = imresize(T, [285 285]);
        end
        [height,width, color] = size(A);

     
        % if image has RGB channels
        if(value2 == 3)  
            hsvImage = rgb2hsv(A);
            % determines desired output for NN based on fruit image
            if ~isempty(strfind(fileName,'watermelon'))
                output = [1 0 0 0 0 0 0 ];
            elseif ~isempty(strfind(fileName,'slice'))
                output = [0 1 0 0 0 0 0 ];
            elseif ~isempty(strfind(fileName,'banana'))
                output = [0 0 1 0 0 0 0];
            elseif ~isempty(strfind(fileName,'orange'))
                output = [0 0 0 1 0 0 0];
            elseif ~isempty(strfind(fileName,'tomato'))
                output = [0 0 0 0 1 0 0];
            else
                [strLength, o] = size(findstr(fileName, '_apple_'));
                [strLength2,o2] = size(findstr(fileName, 'apple'));
                if (strLength == 0)
                    output = [0 0 0 0 0 1 0];  
                else 
                    output = [0 0 0 0 0 0 1];
                end
            end        
                       
            %h computation
            hRanges = zeros(1, hsvBuckets+1);
            
            tRanges = zeros(1, tBuckets+1);

            
            %rRanges = zeros(1, rgbBuckets);
            %gRanges = zeros(1,rgbBuckets);
            %bRanges = zeros(1,rgbBuckets);
            [value2, outputPos] = max(output);

            
            B = uint8( zeros( size(A) ) );  % B holds the pixels to be processed
            C = -1*ones( size(A,1), size(A,2) );  % C holds the h channel only (type double
            
            %rC = -1*ones( size(A,1), size(A,2) );
            %gC = -1*ones( size(A,1), size(A,2) );
            %bC = -1*ones( size(A,1), size(A,2) );
            
            pixels = 0;
            % iterating pixel by pixel and summing each channel
            for row=1:height
                for column=1:width  
                    % if white pixel, darker pixel ignore (background)
                    if ~( (A(row,column,1)> 200 && A(row,column,2)> 200 && A(row,column,3)> 200) || (A(row,column,1)<35 && A(row,column,2)<35 && A(row,column,3)< 35))
                        pixels = pixels + 1;
                        B(row, column,:) = 255;
                        C(row, column) = hsvImage(row, column, 1);
                        
                        %rC(row, column) = A(row, column,1);
                        %gC(row, column) = A(row, column,2);
                        %bC(row, column) = A(row, column,3);
                    end
                end
            end

            D = C(:);
            E = D(D~=-1);
            
            Z =rangefilt(E);
            
            hRanges(1:end-1) = hist( E, hsvBuckets) .^ 0.5; % compress the histogram
            hRanges(1:end-1)  = hRanges(1:end-1) / max(hRanges(1:end-1) );
            
            tRanges(1:end-1) =  hist( Z, tBuckets) .^ 0.5;
           %tRanges(1:end-1)  = tRanges(1:end-1) / max(tRanges(1:end-1));
            
            %rD = rC(:);
            %rE = rD(rD~=-1);
            
            %gD = gC(:);
            %gE = gD(gD~=-1);
            
            %bD = bC(:);
            %bE = bD(bD~=-1);
            
            %rRanges = hist(rE, rgbBuckets) .^ .5;
            %rRanges = rRanges / max(rRanges);
            
            %gRanges = hist(gE, rgbBuckets) .^ .5;
            %gRanges = gRanges / max(gRanges);
            
            %bRanges = hist(rE, rgbBuckets) .^ .5;
            %bRanges = bRanges / max(bRanges);
            
            %rgbInputs = [rRanges gRanges bRanges];
                       
           
            hInputs = hRanges(1:end-1);
            
            tInputs = tRanges(1:end-1);
            
            thRanges = [hRanges(1:end-1) tRanges(1:end-1)];

            %rgbInputs = rgbInputs';
            %hsvInputs = hsvInputs';
            hInputs = hInputs';
            tInputs = tInputs';
            
            thRanges = thRanges';
            
            file = fopen('file.txt','r');
 
            Intro = textscan(file,'%s',3,'Delimiter','\n');
            x = str2double(Intro{1});
 
            numInputs = x(1);
            hiddenNodes1 = x(2);
            hiddenNodes2 = x(3);
            numOut = 7;
 
            hiddenWeights1Out = ones(1, hiddenNodes1);
            hiddenWeights2Out = ones(1,hiddenNodes2);
            outOfOut= ones(1,numOut);
 
            inputs = ones(numInputs,1);
            inputs(1,1) = -1;
            
            if(userEnter == 1)
               for i=2:numInputs
                   inputs(i,1) = rgbInputs(i-1,1);
               end
            end
            if(userEnter == 2)
                for i=2:numInputs
                   inputs(i,1) = hsvInputs(i-1,1);
                end
            end
            if(userEnter == 3)
                for i=2:numInputs
                   inputs(i,1) = hInputs(i-1,1);
                end
            end
            if(userEnter == 4)
                for i=2:numInputs
                   inputs(i,1) = tInputs(i-1,1);
                end
            end
            if(userEnter == 5)
                for i=2:numInputs
                   inputs(i,1) = thRanges(i-1,1);
                end
            end
 
            for i=1: hiddenNodes1
                Intro = textscan(file,'%s',numInputs,'Delimiter','\n');
 
                x = str2double(Intro{1});
 
                summedValue = sum(times(inputs,x));
                sigmoid = 1.0 ./ ( 1.0 + exp(-summedValue));
                hiddenWeights1Out(1,i) = sigmoid;
            end
 
            inputsToHid2 = ones(1,hiddenNodes1 +1);
            inputsToHid2(1,1) = -1;
            for i=2:hiddenNodes1+1
                inputsToHid2(1,i)= hiddenWeights1Out(1,i-1);
            end
            inputsToHid2 = inputsToHid2';
 
 
            for i=1: hiddenNodes2
                Intro = textscan(file,'%s',hiddenNodes1+1,'Delimiter','\n');
 
                x = str2double(Intro{1});
 
                summedValue = sum(times(inputsToHid2,x));
                sigmoid = 1.0 ./ ( 1.0 + exp(-summedValue));
                hiddenWeights2Out(1,i) = sigmoid;
            end
 
 
            inputsToOut = ones(1,hiddenNodes2 +1);
            inputsToOut(1,1) = -1;
 
            for i=2:hiddenNodes2+1
                inputsToOut(1,i)= hiddenWeights2Out(1,i-1);
            end
 
            inputsToOut = inputsToOut';
 
            for i=1: numOut
                Intro = textscan(file,'%s',hiddenNodes2+1,'Delimiter','\n');
 
                x = str2double(Intro{1});
 
                summedValue = sum(times(inputsToOut,x));
                sigmoid = 1.0 ./ ( 1.0 + exp(-summedValue));
                outOfOut(1,i) = sigmoid;
            end
                  fclose(file);
            
            [value, position] = max(outOfOut);
            
            [value2, desiredPosition] = max(output);
            
            if(desiredPosition == position)
                correct = correct + 1;
            end
 
            confusionMatrix(desiredPosition, position) = confusionMatrix(desiredPosition, position) + 1;
            
            total = total + 1;
            
            correct 
            total
        end
    end
end