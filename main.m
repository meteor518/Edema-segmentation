clear;
clc;
%******************************************************
%**********************分割水泡************************
%******************************************************

%% 读入图像
path = '.\image\';
I_original = imread('ori.bmp');
I1 = I_original;
%imshow(I_original);hold on
bluebar0(:,1:4) = 0;  bluebar1(:,1:4) = 0;  bluebar2(:,1:4) = 0;   % 用于存每种颜色的起始坐标
bluebar3(:,1:4) = 0;  bluebar4(:,1:4) = 0;  bluebar5(:,1:4) = 0; 
bluebar6(:,1:4) = 0;  bluebar7(:,1:4) = 0;  bluebar8(:,1:4) = 0; 
bluebar9(:,1:4) = 0;  bluebar10(:,1:4) = 0; bluebar11(:,1:4) = 0; 
bluebar12(:,1:4) = 0; bluebar13(:,1:4) = 0; bluebar14(:,1:4) = 0;
bluebar15(:,1:4) = 0; bluebar16(:,1:4) = 0;
bar0 = 0;  bar1 = 0;  bar2 = 0;  bar3 = 0;  bar4 = 0;  bar5 =0;    % 用于计数每种颜色条个数
bar6 = 0;  bar7 = 0;  bar8 = 0;  bar9 = 0;  bar10 = 0; bar11 =0;
bar12 = 0; bar13 = 0; bar14 = 0; bar15 = 0; bar16 = 0; 

% num = 8;
for num = 0:18
    familyname = '张_';
    gray_deback = 190;      % gray_deback:更接近于目标的灰度值，用于去除背景噪声
    gray_back = 255;        % gray_back:背景灰度域值
    gray_obj = 205;         % gray_obj：目标更精确二值化

    numStr = num2str(num);
    if num < 10
        filename = strcat(familyname,'00', numStr,'.jpg');
    else
        filename = strcat(familyname,'0', numStr,'.jpg');
    end
    temp = imread(strcat(path,filename));
    I_left = temp(1:496,1:496,:);      
    I_left = double(I_left);           % I_color:左侧彩色图
    temp = rgb2gray(temp);
    tempImg = temp(1:496,497:1008);
    tempImg(435:496,:) = 255;
    I_right = tempImg;                         % I：右侧切面灰度图 
    I_right = double(I_right); 
    [m,n] = size(I_right); 
    %% 水肿分割，并将映射信息存于bubbleline矩阵
        %*****info_seg函数****
    [bubbleline,bubblenum] = info_seg(I_right);
 
     %% 彩色图上标记，绿色线长大概335个像素
    colorrow = 0;    % 记录绿条开始的行
    colorcol = 0;    % 记录绿条开始的列
    for j = 1:n
        for i = 1:m
            if I_left(i,j,1)==I_left(i,j,2) && I_left(i,j,3)==I_left(i,j,2) % 找到绿条的开始位置
            else
                colorrow = i;
                colorcol = j;
                break
            end
        end
        if colorrow
            break
        end
    end

    %% 按水泡高度分配线条颜色，用颜色反映泡的高度，划分17个等级
    [bubbleline_value,bubbleline_index] = sort(bubbleline(:,1));       % 按水泡的高度排序

    for i=1:bubblenum
        if i>1
            for j=1:i-1
                if bubbleline(bubbleline_index(i),2)>=bubbleline(bubbleline_index(j),3)||bubbleline(bubbleline_index(i),3)<=bubbleline(bubbleline_index(j),2)
                else
                    colorrow = colorrow+1;
                    break
                end
            end
        end
        % 0
        if bubbleline(bubbleline_index(i),1)>=250
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335); 
            I_original(colorrow,col1:col2,2) = 0;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar0 = bar0+1;
            bluebar0(bar0,1) = colorrow;
            bluebar0(bar0,2) = col1;
            bluebar0(bar0,3) = col2;
            bluebar0(bar0,4) = 1;
        end
        % 1
        if bubbleline(bubbleline_index(i),1)>=240 && bubbleline(bubbleline_index(i),1)<250
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 16;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar1 = bar1+1;
            bluebar1(bar1,1) = colorrow;
            bluebar1(bar1,2) = col1;
            bluebar1(bar1,3) = col2;
            bluebar1(bar1,4) = 2;
        end
        % 2
        if bubbleline(bubbleline_index(i),1)>=230 && bubbleline(bubbleline_index(i),1)<240
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 32;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar2 = bar2+1;
            bluebar2(bar2,1) = colorrow;
            bluebar2(bar2,2) = col1;
            bluebar2(bar2,3) = col2;
            bluebar2(bar2,4) = 3;
        end
        % 3
        if bubbleline(bubbleline_index(i),1)>=220 && bubbleline(bubbleline_index(i),1)<230
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 48;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar3 = bar3+1;
            bluebar3(bar3,1) = colorrow;
            bluebar3(bar3,2) = col1;
            bluebar3(bar3,3) = col2;
            bluebar3(bar3,4) = 4;
        end
        % 4
        if bubbleline(bubbleline_index(i),1)>=210 && bubbleline(bubbleline_index(i),1)<220
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 64;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar4 = bar4+1;
            bluebar4(bar4,1) = colorrow;
            bluebar4(bar4,2) = col1;
            bluebar4(bar4,3) = col2;
            bluebar4(bar4,4) = 5;
        end
        % 5
        if bubbleline(bubbleline_index(i),1)>=200 && bubbleline(bubbleline_index(i),1)<210
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 80;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar5 = bar5+1;
            bluebar5(bar5,1) = colorrow;
            bluebar5(bar5,2) = col1;
            bluebar5(bar5,3) = col2;
            bluebar5(bar5,4) = 6;
        end
        % 6
        if bubbleline(bubbleline_index(i),1)>=190 && bubbleline(bubbleline_index(i),1)<200
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 96;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar6 = bar6+1;
            bluebar6(bar6,1) = colorrow;
            bluebar6(bar6,2) = col1;
            bluebar6(bar6,3) = col2;
            bluebar6(bar6,4) = 7;
        end
        % 7
        if bubbleline(bubbleline_index(i),1)>=180 && bubbleline(bubbleline_index(i),1)<190
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 112;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar7 = bar7+1;
            bluebar7(bar7,1) = colorrow;
            bluebar7(bar7,2) = col1;
            bluebar7(bar7,3) = col2;
            bluebar7(bar7,4) = 8;
        end
        % 8
        if bubbleline(bubbleline_index(i),1)>=170 && bubbleline(bubbleline_index(i),1)<180
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 128;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar8 = bar8+1;
            bluebar8(bar8,1) = colorrow;
            bluebar8(bar8,2) = col1;
            bluebar8(bar8,3) = col2;
            bluebar8(bar8,4) = 9;
        end
        % 9
        if bubbleline(bubbleline_index(i),1)>=160 && bubbleline(bubbleline_index(i),1)<170
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 144;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar9 = bar9+1;
            bluebar9(bar9,1) = colorrow;
            bluebar9(bar9,2) = col1;
            bluebar9(bar9,3) = col2;
            bluebar9(bar9,4) = 10;
        end
        % 10
        if bubbleline(bubbleline_index(i),1)>=150 && bubbleline(bubbleline_index(i),1)<160
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 160;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar10 = bar10+1;
            bluebar10(bar10,1) = colorrow;
            bluebar10(bar10,2) = col1;
            bluebar10(bar10,3) = col2;
            bluebar10(bar10,4) = 11;
        end
        % 11
        if bubbleline(bubbleline_index(i),1)>=140 && bubbleline(bubbleline_index(i),1)<150
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 176;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar11 = bar11+1;
            bluebar11(bar11,1) = colorrow;
            bluebar11(bar11,2) = col1;
            bluebar11(bar11,3) = col2;
            bluebar11(bar11,4) = 12;
        end
        % 12
        if bubbleline(bubbleline_index(i),1)>=130 && bubbleline(bubbleline_index(i),1)<140
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 192;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar12 = bar12+1;
            bluebar12(bar12,1) = colorrow;
            bluebar12(bar12,2) = col1;
            bluebar12(bar12,3) = col2;
            bluebar12(bar12,4) = 13;
        end
        % 13
        if bubbleline(bubbleline_index(i),1)>=120 && bubbleline(bubbleline_index(i),1)<130
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 208;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar13 = bar13+1;
            bluebar13(bar13,1) = colorrow;
            bluebar13(bar13,2) = col1;
            bluebar13(bar13,3) = col2;
            bluebar13(bar13,4) = 14;
        end
        % 14
        if bubbleline(bubbleline_index(i),1)>=110 && bubbleline(bubbleline_index(i),1)<120
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 224;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar14 = bar14+1;
            bluebar14(bar14,1) = colorrow;
            bluebar14(bar14,2) = col1;
            bluebar14(bar14,3) = col2;
            bluebar14(bar14,4) = 15;
        end
        % 15
        if bubbleline(bubbleline_index(i),1)>=100 && bubbleline(bubbleline_index(i),1)<110
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 240;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar15 = bar15+1;
            bluebar15(bar15,1) = colorrow;
            bluebar15(bar15,2) = col1;
            bluebar15(bar15,3) = col2;
            bluebar15(bar15,4) = 16;
        end
        % 16
        if bubbleline(bubbleline_index(i),1)<100
            col1 = round(colorcol+bubbleline(bubbleline_index(i),2)/n*335);
            col2 = round(colorcol+bubbleline(bubbleline_index(i),3)/n*335);
            I_original(colorrow,col1:col2,2) = 255;
            if bubbleline(bubbleline_index(i),4)
                I_original(colorrow,col1:col2,1) = 255;
                I_original(colorrow,col1:col2,3) = 0;
            else
                I_original(colorrow,col1:col2,1) = 0;
                I_original(colorrow,col1:col2,3) = 255;
            end
            bar16 = bar16+1;
            bluebar16(bar16,1) = colorrow;
            bluebar16(bar16,2) = col1;
            bluebar16(bar16,3) = col2;
            bluebar16(bar16,4) = 17;
        end
    end
    clearvars -except path I_original I1 bar0 bar1 bar2 bar3 bar4 bar5 bar6 bar7 bar8 bar9 bar10 bar11 bar12 bar13 bar14 bar15 bar16 ...
        bluebar0 bluebar1 bluebar2 bluebar3 bluebar4 bluebar5 bluebar6 bluebar7 bluebar8 bluebar9 bluebar10 bluebar11 bluebar12 bluebar13 ...
        bluebar14 bluebar15 bluebar16       
end
figure;imshow(I_original);hold on

%%  把所有的蓝条存入一个大矩阵
I_barmark =  I_original;
bluebar = [bluebar0;bluebar1;bluebar2;bluebar3;bluebar4;bluebar5;...
    bluebar6;bluebar7;bluebar8;bluebar9;bluebar10;bluebar11;bluebar12;
    bluebar13;bluebar14;bluebar15;bluebar16];                           % 把各种蓝色条按颜色号矩阵合成一个蓝色条矩阵
% Image_final = edema_show(bluebar,I1);
% figure;imshow(uint8(Image_final));