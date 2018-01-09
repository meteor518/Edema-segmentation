function [bubbleline,LTnum] = info_seg(I_right)
    [m,n] = size(I_right); 
    gray_deback = 180;      % gray_deback:更接近于目标的灰度值，用于去除背景噪声
    gray_back = 255;        % gray_back:背景灰度域值
    gray_obj = 205;         % gray_obj：目标更精确二值化
    %figure;imshow(uint8(I));title('original');
   
    %% 高斯滤波
    g = fspecial('gaussian',[5 5],5);
    I_g = imfilter(I_right,g,'replicate');  % I_g：高斯滤波后图像
    
    %% 各向异性扩散滤波
    niter = 60;
    lambda = 0.1;
    kappa = 60;
    option = 1;
    I_PM = anisodiff_PM(I_g,niter, kappa, lambda, option); % I_PM：各向异性扩散滤波后图像
    %figure;imshow(uint8(I_PM));title('PM');
    %% 二值化，接近于灰色值的即为目标区，标为白色，背景色为黑色
    % 第一次二值化，为了得到ILM和RPE层后去除背景噪声
    I_bw = I_PM;
    black = abs(I_bw-gray_deback*ones(m,n));
    white = abs(I_bw-gray_back*ones(m,n));
    for i = 1:m
        for j = 1:n
            if black(i,j) < white(i,j)
                I_bw(i,j) = 255;
            else
                I_bw(i,j) = 0;
            end
        end
    end
    % 去除面积小于200的噪声点
    [LT,LTnum] = bwlabel(I_bw);
    S = regionprops(LT,'all');
    I_bw = ismember(LT, find([S.Area]>200));
%     figure;imshow(I_bw);title('二值化');
   
    %% 标记最上层ILM
    % 对于二值化图像，每列寻找第一个白色像素点，记为ILM层
   ILMnum = 0;
    for j=1:n
        for i=1:m
            if I_bw(i,j) == 1   % 寻找每列第一个黑像素点，即为ILM
                ILMnum = ILMnum+1;
                ILMrow(ILMnum) = i;  % 保存ILM层的行和列的坐标
                ILMcol(ILMnum) = j;            
                break
            end
        end
    end
    %% 完整性检测
    ILMrow = Integrity_test(ILMrow,ILMcol,ILMnum);
    
    J(:,:,1) = I_right;
    J(:,:,2) = I_right;
    J(:,:,3) = I_right;
    for i=1:ILMnum
        J(ILMrow(i),ILMcol(i),1) = 255;  % 把ILM层标记为红色
        J(ILMrow(i),ILMcol(i),2) = 0;
        J(ILMrow(i),ILMcol(i),3) = 0;
    end   
%     figure;imshow(uint8(J));title('ILM');
    
    %% 分割最下层RPE层
    % 每列灰度值变化率最大的前两个一般为ILM和RPE层，根据行数判定行数大的即为RPE层
    RPEnum = 0;
    for j=ILMcol(1):ILMcol(ILMnum)
        RPEnum = RPEnum+1;
        x1 = 1:m;
        y1 = I_PM(x1,j);
      % plot(x1,y1);hold on
        [pksmax,locmax] = findpeaks(y1);   % 寻找每列的极大值;pksmax为各极大值的像素值，locmax是极大值对应的行数位置
        MaxPks = [locmax,pksmax];
        [pksmin,locmin] = findpeaks(-y1);  % 寻找每列的极小值;pksmin为各极小值的像素值，locmax是极小值对应的行数位置
        MinPks = [locmin,-pksmin];
      % plot(locmax,pksmax,'b+');
      % plot(locmin,-pksmin,'ro');
        Pks = [MaxPks;MinPks];             % 把所有极值存入同一矩阵Pks
        [pks_value,pks_index] = sort(Pks(:,1));  % 按所有极值点的行数进行排序
        pks_diff = zeros(length(pks_value),1); % pks_diff：存放两相邻极值点的差值，即一阶导（变化率）
        
        for i=1:length(pks_value)
            if i==1
                pks_diff(i) = 0;
            else
                pks_diff(i) = Pks(pks_index(i),2)-Pks(pks_index(i-1),2);
            end
        end
        
        [pksdiff_value,pksdiff_index] = sort(pks_diff); % 对变化率进行排序，由白到黑即变化降得最快的位置即为分界
                                                        % 因由白到黑，黑减白为负值，故差值最小的前两个即为变化最快的，一般ILM或RPE
        if Pks(pks_index(pksdiff_index(1)),1) < Pks(pks_index(pksdiff_index(2)),1)% 取前两个的行数进行比较，大的判为RPE层，存入RPErow行、RPEcol列
            RPErow(RPEnum) = Pks(pks_index(pksdiff_index(2)),1);
        else
            RPErow(RPEnum) = Pks(pks_index(pksdiff_index(1)),1);
        end
        
        RPEcol(RPEnum) = j;
    end
    %% 完整性检测
    RPErow = Integrity_test(RPErow,RPEcol,RPEnum);
    RPErow = RPErow+2;
    for i=1:RPEnum
        J(RPErow(i),RPEcol(i),1) = 255;  % 把RPE层标记为黄色
        J(RPErow(i),RPEcol(i),2) = 255;
        J(RPErow(i),RPEcol(i),3) = 0;
    end  
%     figure;imshow(uint8(J));title('RPE');
    
    %% 对I_PM图像去背景噪声，上下变为黑色
    for j=1:RPEnum
        I_PM(RPErow(j):m,RPEcol(j)) = 0;   %RPE层以下的背景变为白色
    end
    
    for j=1:n
        for i=1:m
            if J(i,j,1)==255&&J(i,j,2)==0  %ILM层以上的背景变为白色
                for t=1:i-1
                    I_PM(t,j) = 0;
                end            
                break
            end
        end
    end    
%     figure;imshow(uint8(I_PM));title('去噪声后的I');
   
    %% 二次二值化，准确分割目标区，水泡为白色
    I_bw = I_PM;
    black = abs(I_bw-gray_obj*ones(m,n));
    white = abs(I_bw-gray_back*ones(m,n));
    for i = 1:m
        for j = 1:n
            if black(i,j) < white(i,j)
                I_bw(i,j) = 0;
            else
                I_bw(i,j) = 255;
            end
        end
    end
%     figure;imshow(uint8(I_bw));title('new I_bw');
    %% 水泡小于40的去除
    [LT,LTnum] = bwlabel(I_bw);
    S = regionprops(LT,'all');
    I_bw = ismember(LT, find([S.Area]>45));
%     figure;imshow(I_bw);title('new I_bw');
    %% 高度小于90的认为是伪水泡，去除
    [LT,LTnum] = bwlabel(I_bw);
    S = regionprops(LT,'all');
    for i=1:LTnum
        for j=floor(S(i).BoundingBox(1)):floor(S(i).BoundingBox(1)+S(i).BoundingBox(3))
            if RPErow(j)-ILMrow(j)>80
%                 fprintf('第%d个高度是%d\n', i,j)
                break
            else if j==floor(S(i).BoundingBox(1)+S(i).BoundingBox(3))
                    I_bw1 = ismember(LT, find([S.Area]~=S(i).Area));
                    I_bw = I_bw & I_bw1;
                end
            end
        end
    end
    figure;imshow(I_bw);
    %% 层上层下水肿区分及水泡映射信息存储，存于bubbleline
    % 根据水肿下边界距离RPE层边界的距离区分
%     I_color(:,:,1) = I_right;   % I_color表示左侧OCT彩色分割图
%     I_color(:,:,2) = I_right;
%     I_color(:,:,3) = I_right;
    [LT,LTnum] = bwlabel(I_bw);
    S = regionprops(LT,'all');
    bubbleline = zeros(LTnum,4); % bubbleline用于存水泡映射信息
 % 第一列存水泡中心高度，二三列存水泡左右边界,第四列存flag，表当前水泡分类，flag=1,红色层下，flag=0蓝色层上
    for k=1:LTnum
        bubbleline(k,1) = floor(S(k).Centroid(2));
        bubbleline(k,2) = floor(S(k).BoundingBox(1));
        bubbleline(k,3) = floor(S(k).BoundingBox(1)+S(k).BoundingBox(3));
        flag = false;       % false表示层上水肿，蓝色；true表示层下，红色
        for j=floor(S(k).BoundingBox(1)):floor(S(k).BoundingBox(1)+S(k).BoundingBox(3))
            for i=floor(S(k).BoundingBox(2)+S(k).BoundingBox(4)):-1:floor(S(k).BoundingBox(2))
                if LT(i,j)==k
                    break
                end
            end
            if abs(i-RPErow(j))<15
                flag = true;
                break
            end
        end
        bubbleline(k,4) = flag;
%         if flag
%              for j=floor(S(k).BoundingBox(1)):floor(S(k).BoundingBox(1)+S(k).BoundingBox(3))
%                 for i=floor(S(k).BoundingBox(2)+S(k).BoundingBox(4)):-1:floor(S(k).BoundingBox(2))
%                     if LT(i,j)==k
%                         I_color(i,j,1) = 255;
%                         I_color(i,j,2) = 0;
%                         I_color(i,j,3) = 0;
%                     end
%                 end
%              end
%         else
%             for j=floor(S(k).BoundingBox(1)):floor(S(k).BoundingBox(1)+S(k).BoundingBox(3))
%                 for i=floor(S(k).BoundingBox(2)+S(k).BoundingBox(4)):-1:floor(S(k).BoundingBox(2))
%                     if LT(i,j)==k
%                         I_color(i,j,1) = 0;
%                         I_color(i,j,2) = 0;
%                         I_color(i,j,3) = 255;
%                     end
%                 end
%              end
%         end
    end