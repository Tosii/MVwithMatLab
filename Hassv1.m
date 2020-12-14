
%i figured i'll just ignore bottles that are not upright position

%i decided to go with detecting circles, as they are constant size 
%Simply turn image to black and white, adjusting threshold took few tries
%but 0.4 seemed suitable for this.


%first search capless bottles.
%Next step is to find bottles with caps, as they tend to be quite close to
%the size of empty bottle opening ;)

%then it's pretty much simply just searching for circles and counting them

clear all;


bsup= [3,8,14,16];
full= [4,6,7,8,10,15,18,21,22,24];
fallen = [ 10,15 ];
glass = [ 12,13,22 ];
alla=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24];


for i = alla%union(bsup,full)%[3]
    close all;
    img=imread(sprintf('img/bottle_crate_%02i.png',i));
    
    %%blackywhity image
    imgBW = im2bw(img,0.4);
    
    %%spot caps and scheisse
    imgSE = imopen(imgBW, strel('octagon',9) );
    
    %%substract caps from image
    imgBW2 = imgBW-imgSE
    
    %dilate substracted image abit 
    imgBW2 = imopen(imgBW2,strel('square',2));
  

    %% EMPTY
    [BottleNoCapCentersUnfixed,radii] = imfindcircles(imgBW2,[10,25],'ObjectPolarity','dark','Sensitivity',0.93);
    BottleNoCapCenters = []
    for x = 1:size(BottleNoCapCentersUnfixed,1)
        conflict = 0
        for y = 1:size(BottleNoCapCentersUnfixed,1)
            if x == y
                break
            end
            X = [BottleNoCapCentersUnfixed(x,1),BottleNoCapCentersUnfixed(x,2);BottleNoCapCentersUnfixed(y,1),BottleNoCapCentersUnfixed(y,2)]
            dist= pdist(X,'euclidean');
            if dist < 20
                conflict = 1
                break
            end
        end
        if conflict == 0
            BottleNoCapCenters = [BottleNoCapCenters ;[BottleNoCapCentersUnfixed(x,1),BottleNoCapCentersUnfixed(x,2) ] ]
        end
    end    
    
    
    
    %% CAPS
    [BottleWithCapCenters,rcb] = imfindcircles(img,[15,25],'ObjectPolarity','bright','Sensitivity',0.88)
    BottleWithCapCentersFixed = []
    
    %%lets filter empty bottles from BottleWithCapCenters
    for x = 1:size(BottleWithCapCenters,1)
        conflict = 0
        for y = 1:size(BottleNoCapCenters,1)
            X = [BottleWithCapCenters(x,1),BottleWithCapCenters(x,2);BottleNoCapCenters(y,1),BottleNoCapCenters(y,2)]
            dist= pdist(X,'euclidean');
            if dist < 20
                conflict = 1
                break
            end
        end
        if conflict == 0
            BottleWithCapCentersFixed = [BottleWithCapCentersFixed ;[BottleWithCapCenters(x,1),BottleWithCapCenters(x,2) ] ]
        end
    end
        
            
    
 
    
    %% BOTTOMS UP CUT(CBA,CBB)
    [BottleWithBottomsUPBW,rba] = imfindcircles(imgBW,[28,40],'ObjectPolarity','bright','Sensitivity',0.84)
    [BottleWithBottomsUPBW2,rbb] = imfindcircles(imgBW2,[22,40],'ObjectPolarity','dark','Sensitivity',0.97)
    BottleWithBottomsUPFIXED = []
    for x = 1:size(BottleWithBottomsUPBW,1)
        
        for y = 1:size(BottleWithBottomsUPBW2,1)
            %disp("cba cbb distancee")
            X = [BottleWithBottomsUPBW(x,1),BottleWithBottomsUPBW(x,2);BottleWithBottomsUPBW2(y,1),BottleWithBottomsUPBW2(y,2)]
            dist= pdist(X,'euclidean');
            if dist < 5
                BottleWithBottomsUPFIXED = [BottleWithBottomsUPFIXED ;[BottleWithBottomsUPBW(x,1),BottleWithBottomsUPBW(x,2) ] ]
            end
        end
    end

    
    
   % figure;
    subplot(2,2,1);
    a = size(BottleNoCapCenters,1);
    b = size(BottleWithCapCentersFixed,1);
    c = size(BottleWithBottomsUPFIXED,1);
    imshow(img),title(sprintf('n:%02i/24 empty: %02i, full: %02i upsidedown:%02i',i,a,b,c));
    
    %%print empties
    hold on;
    for n = 1:length(BottleNoCapCenters)
        plot( BottleNoCapCenters(n,1), BottleNoCapCenters(n,2) ,'r+', 'MarkerSize', 7,'LineWidth',1);
    end
    
    %%print cappeds
    for n = 1:size(BottleWithCapCentersFixed,1)
        plot( BottleWithCapCentersFixed(n,1), BottleWithCapCentersFixed(n,2) ,'g+', 'MarkerSize', 7,'LineWidth',1);
    end
    
    %%print bottoms upped
    for n = 1:size(BottleWithBottomsUPFIXED,1)
        plot( BottleWithBottomsUPFIXED(n,1), BottleWithBottomsUPFIXED(n,2) ,'b+', 'MarkerSize', 10,'LineWidth',1);
    end
    
    subplot(2,2,2);
    hold on;
    imshow(imgBW),title('B/W');
    for n = 1:size(BottleWithBottomsUPBW,1)
        plot( BottleWithBottomsUPBW(n,1), BottleWithBottomsUPBW(n,2) ,'b+', 'MarkerSize', 10,'LineWidth',1);
    end
    
    subplot(2,2,3);
    imshow(imgSE),title('caps etc');
    
    subplot(2,2,4);
    hold on;
    imshow(imgBW2),title('caps etc removed');  
    for n = 1:size(BottleWithBottomsUPBW2,1)
        plot( BottleWithBottomsUPBW2(n,1), BottleWithBottomsUPBW2(n,2) ,'b+', 'MarkerSize', 10,'LineWidth',1);
    end

    pause();

end
