clear;
% go through our fruits directory image by image
DATA_DIR = 'fruits4\';
fruit_dir = dir(DATA_DIR);

hSet = fopen('hSet.txt', 'wt');
tSet = fopen('tSet.txt', 'wt');
thSet = fopen('thSet.txt', 'wt');

hsvBuckets = 20;  
tBuckets = 25;
DISPLAY_IMAGES =    false; 

%histogram = ones(154, tBuckets + 1);

histInd = 0;
for index = fruit_dir'
    if ~(strcmp(index.name,'.') || (strcmp(index.name,'..')))
        fileName = strcat(DATA_DIR, index.name);
        T = imread(fileName);
        fprintf('Proc: %d\n', histInd);
        
        [height,width, color] = size(T);
        [value1,value2] = size(size(T));
        
        if( height > 285 || width > 285)
            A = imresize(T, [285 285]);
        end
        [height,width, color] = size(A);

        

        % if image has RGB channels
        if(value2 == 3 && color ~= 0)  
            histInd = histInd + 1;%
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
                       
            %hsv computation
            hRanges = zeros(1, hsvBuckets+1);
            
            tRanges = zeros(1, tBuckets+1);

            
%             rRanges = zeros(1, rgbBuckets);
%             gRanges = zeros(1,rgbBuckets);
%             bRanges = zeros(1,rgbBuckets);
            [value2, outputPos] = max(output);

            
            B = uint8( zeros( size(A) ) );  % B holds the pixels to be processed
            C = -1*ones( size(A,1), size(A,2) );  % C holds the h channel only (type double)
            
%             rC = -1*ones( size(A,1), size(A,2) );
%             gC = -1*ones( size(A,1), size(A,2) );
%             bC = -1*ones( size(A,1), size(A,2) );

            
            pixels = 0;
            % iterating pixel by pixel and summing each channel
            for row=1:height
                for column=1:width  
                    % if white pixel, darker pixel ignore (background)
                    if ~( (A(row,column,1)> 200 && A(row,column,2)> 200 && A(row,column,3)> 200) || (A(row,column,1)<35 && A(row,column,2)<35 && A(row,column,3)< 35))
                        pixels = pixels + 1;
                        B(row, column,:) = 255;
                        C(row, column) = hsvImage(row, column, 1);
%                         rC(row, column) = A(row, column,1);
%                         gC(row, column) = A(row, column,2);
%                         bC(row, column) = A(row, column,3);
                        
                    end
                end
            end

            D = C(:);
            E = D(D~=-1);
            
            Z = rangefilt(E);

%             rD = rC(:);
%             rE = rD(rD~=-1);
%             
%             gD = gC(:);
%             gE = gD(gD~=-1);
%             
%             bD = bC(:);
%             bE = bD(bD~=-1);
%             
%             rRanges = hist(rE, rgbBuckets) .^ .5;
%             rRanges = rRanges / max(rRanges);
%             
%             gRanges = hist(gE, rgbBuckets) .^ .5;
%             gRanges = gRanges / max(gRanges);
%             
%             bRanges = hist(rE, rgbBuckets) .^ .5;
%             bRanges = bRanges / max(bRanges);
%             
%             rgbRanges = [rRanges bRanges gRanges outputPos];
            
            hRanges(1:end-1) = hist( E, hsvBuckets) .^ 0.5; % compress the histogram
            hRanges(1:end-1)  = hRanges(1:end-1) / max(hRanges(1:end-1) );
            
            tRanges(1:end-1) =  hist( Z, tBuckets) .^ 0.5;
            %tRanges(1:end-1)  = tRanges(1:end-1) / max(tRanges(1:end-1));

%             fprintf(rgbSet, '%.4f ', rRanges);
%             fprintf(rgbSet, '%.4f ', gRanges);
%             fprintf(rgbSet, '%.4f ', bRanges);
%             fprintf(rgbSet, '%d ', output);
%             fprintf(rgbSet,'\n');
%             
        
            thRanges = [hRanges(1:end-1) tRanges(1:end-1)];
            fprintf(thSet, '%.4f ', thRanges);
            fprintf(thSet, '%d ', output);
            fprintf(thSet,'\n');
            
            
            
             fprintf(tSet, '%.4f ', tRanges(1:end-1));
             fprintf(tSet, '%d ', output);
             fprintf(tSet,'\n');
            
            %tRanges(end) = outputPos;
            
            %hRanges(end) = outputPos;                       
            %histogram(histInd, :) = tRanges; % append RGB
            
            if DISPLAY_IMAGES
                figure(1); image(A); axis image;
                Z =rangefilt(A);
                figure(2); image(Z); axis image;
                figure(3); bar( hRanges(1:end-1)  );
                drawnow;
            end
        end
    end
end
fclose(hSet); 
fclose(tSet);
fclose(thSet);
% 
% figure(4);
% histogram = sortrows(histogram, tBuckets+1);
% subplot( 1, 2, 1); 
% imagesc(histogram(:,1:end-1));
% set(gca, 'ydir', 'normal');
% xlabel('Stacked Histograms Ordered by Class');
% subplot( 1, 2, 2);
% plot(histogram(:,end), 1:size(histogram,1),'+');
% axis( [1 7 1 size(histogram,1)]);
% xlabel('Class');

