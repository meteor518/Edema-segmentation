function Image_final = edema_show(bluebar,I1)
[bm,bn] = size(bluebar);                    % bm,bn:整体蓝色条矩阵的大小
[bar_value,bar_index] = sort(bluebar(:,1)); % 把蓝色矩阵按条的行数排序
barcol = 1;         % barcol:用于将蓝色矩阵转为按同行排列的矩阵时，控制列；同一高度的颜色条属于同4列
barrow = 1;         % barrow:用于将蓝色矩阵转为按同行排列的矩阵时，控制行；
for i=1:bm
    if bar_value(i)>0
        blueline(barrow,barcol:barcol+3) = bluebar(bar_index(i),1:4);   % 取到矩阵的第一条线，blueline：用于存最后按扫描线高度排序的矩阵
        barstart = i;
        break
    end
end

for i=barstart+1:bm
    if bar_value(i)-bar_value(i-1) > 1    % 如果当前蓝色条与上一个差大于1，表示不属于同一高度，所以列指针+4，行指针回到行首
        barcol = barcol+4;
        barrow = 1;
        blueline(barrow,barcol:barcol+3) = bluebar(bar_index(i),1:4);
    else
        barrow = barrow+1;                 % 属于同一高度的，列指针不变，行指针+1
        blueline(barrow,barcol:barcol+3) = bluebar(bar_index(i),1:4);
    end
end

%% 把所有表示水泡的蓝色线，相邻两条扫描线间的蓝线根据高度、是否重叠、宽度差等判别条件进行连接，形成水泡区域

[blm,bln] = size(blueline);     % blueline：按扫描行存储的蓝色条坐标，blm,bln为blueline的矩阵大小
% temp(1,:) = 0;                  % temp,temp1为两个指针，用于判断相邻两个扫描线上蓝色条是否属于同一个水泡
% temp1(1,:) = 0;

edge_point(:,1:3) = 0;          % edge_point用于存属于同一个泡的蓝条坐标

Imagebubble1 = I1;               % Imagebubble：存储所有形成水泡后的图像
Imagebubble_num = 1;            % Imagebubble_num：还有水泡图的个数
I_original = I1;
count = 0;

for j=4:4:bln           % bubbleline中每四列存的是一行扫描线的信息，所以步长为4
%    j=4;
    flag = 1;           % flag：用于退出循环，若找到下一扫描行属于同一个水泡的蓝色就令flag=0，进行下两行比较
    [value,index] = sort(blueline(:,j));
%      i=3;
    for i=1:blm
        flag = 1;
        point = 1;
        edge_point(:,1:3) = 0;
        I_previous = I_original;
        I_original = I1;
        if value(i)>0               % 取每一个扫描行中蓝线，按颜色号从小到大取
            count = count+1;
            temp = blueline(index(i),j-3:j);  % temp当前蓝条
            if I_barmark(temp(1),temp(2),1)==255 && I_barmark(temp(1),temp(2),3)==0
                color(1,1,1) = 255;
                color(1,1,2) = 0;
                color(1,1,3) = 10*(count-1);
            else
            % color用于赋值水泡显示颜色
                color(1,1,2) = 200;
                color(1,1,3) = 255;
                color(1,1,1) = 10*(count-1);
            end
            blueline(index(i),j-3:j) = 0;     % 取出满足条件的蓝色条后，原矩阵该条清零
            edge_point(point,1) = temp(1)-round((temp(3)-temp(2))*3/8);     % 每次都一行线上面自定义一个点，形成封闭区
            edge_point(point,2:3) = round((temp(2)+temp(3))/2);
            point = point+1;
            edge_point(point,:) = temp(1:3);
            k = j+4;
            while k<=bln
                [value1,index1] = sort(blueline(:,k));
                for i1=1:blm
                    if value1(i1)>0
                        temp1 = blueline(index1(i1),k-3:k);   % 取出下一行最小颜色序号的条
                        break
                    end
                end
                if temp1
                    for i3=i1:blm
                        temp1 = blueline(index1(i3),k-3:k);
                        if temp1(4)==temp(4)
                            if temp(2)>=temp1(3)||temp(3)<=temp1(2)
                                if i3==blm
                                    point = point+1;
                                    edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                    edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                    flag = 0;
                                    break
                                end
                            else if abs(temp(3)-temp(2)-(temp1(3)-temp1(2)))<60||abs(temp(3)-temp(2)-(temp1(3)-temp1(2)))<min(temp(3)-temp(2),temp1(3)-temp1(2))                    
                                    point = point+1;
                                    edge_point(point,:) = temp1(1:3);
                                    if k==bln
                                        point = point+1;
                                        edge_point(point,1) = temp1(1)+round((temp1(3)-temp1(2))*3/8);
                                        edge_point(point,2:3) = round((temp1(2)+temp1(3))/2);
                                    end
                                    blueline(index1(i3),k-3:k) = 0;
                                    temp = temp1;
                                    break
                                else
                                    if i3==blm
                                        point = point+1;
                                        edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                        edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                        flag = 0;
                                        break
                                    end
                                end
                            end
                        else if abs(temp1(4)-temp(4))==1
                                if temp(2)>=temp1(3)||temp(3)<=temp1(2)
                                    if i3==blm
                                        point = point+1;
                                        edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                        edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                        flag = 0;
                                        break
                                    end
                                else if abs(temp(3)-temp(2)-(temp1(3)-temp1(2)))<60||abs(temp(3)-temp(2)-(temp1(3)-temp1(2)))<min(temp(3)-temp(2),temp1(3)-temp1(2))
                                        point = point+1;
                                        edge_point(point,:) = temp1(1:3);
                                        if k==bln
                                            point = point+1;
                                            edge_point(point,1) = temp1(1)+round((temp1(3)-temp1(2))*3/8);
                                            edge_point(point,2:3) = round((temp1(2)+temp1(3))/2);
                                        end
                                        blueline(index1(i3),k-3:k) = 0;
                                        temp = temp1;
                                        break
                                    else
                                        if i3==blm
                                            point = point+1;
                                            edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                            edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                            flag = 0;
                                            break
                                        end
                                    end
                                end
                            else if abs(temp1(4)-temp(4))==2
                                    if temp(2)>=temp1(3)||temp(3)<=temp1(2)
                                        if i3==blm
                                            point = point+1;
                                            edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                            edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                            flag = 0;
                                            break
                                        end
                                    else if abs(temp(3)-temp(2)-(temp1(3)-temp1(2)))<60||abs(temp(3)-temp(2)-(temp1(3)-temp1(2)))<min(temp(3)-temp(2),temp1(3)-temp1(2))
                                            point = point+1;
                                            edge_point(point,:) = temp1(1:3);
                                            if k==bln
                                                point = point+1;
                                                edge_point(point,1) = temp1(1)+round((temp1(3)-temp1(2))*3/8);
                                                edge_point(point,2:3) = round((temp1(2)+temp1(3))/2);
                                            end
                                            blueline(index1(i3),k-3:k) = 0;
                                            temp = temp1;
                                            break
                                        else
                                            if i3==blm
                                                point = point+1;
                                                edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                                edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                                flag = 0;
                                                break
                                            end
                                        end
                                    end
                                else if abs(temp1(4)-temp(4))==3
                                        if temp(2)>=temp1(3)||temp(3)<=temp1(2)
                                            if i3==blm
                                                point = point+1;
                                                edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                                edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                                flag = 0;
                                                break
                                            end
                                        else if abs(temp(3)-temp(2)-(temp1(3)-temp1(2)))<60||abs(temp(3)-temp(2)-(temp1(3)-temp1(2)))<min(temp(3)-temp(2),temp1(3)-temp1(2))
                                                point = point+1;
                                                edge_point(point,:) = temp1(1:3);
                                                if k==bln
                                                    point = point+1;
                                                    edge_point(point,1) = temp1(1)+round((temp1(3)-temp1(2))*3/8);
                                                    edge_point(point,2:3) = round((temp1(2)+temp1(3))/2);
                                                end
                                                blueline(index1(i3),k-3:k) = 0;
                                                temp = temp1;
                                                break
                                            else
                                                if i3==blm
                                                    point = point+1;
                                                    edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                                    edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                                    flag = 0;
                                                    break
                                                end
                                            end
                                        end
                                    else
                                        point = point+1;
                                        edge_point(point,1) = temp(1)+round((temp(3)-temp(2))*3/8);
                                        edge_point(point,2:3) = round((temp(2)+temp(3))/2);
                                        flag = 0;
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                if flag
                    k = k+4;
                else
                    break
                end
            end
        end
        % 插值，边缘点光滑连接
        if edge_point(1,1)
            x1 = edge_point(1,1);
            for ii=2:length(edge_point(:,1))
                if edge_point(ii,1)~=0
                    x1 = [x1;edge_point(ii,1)];
                end
            end
            y1 = edge_point(1:length(x1),2);
            y2 = edge_point(1:length(x1),3);
            plot(y1,x1,'or');
            hold on;
            plot(y2,x1,'or');
            hold on;
            Row = min(x1):1:max(x1);
            Col1 = interp1(x1,y1,Row,'PCHIP');
            Col2 = interp1(x1,y2,Row,'PCHIP');
            plot(Col1,Row,'g');
            hold on
            plot(Col2,Row,'g');
            % 连起来的区域赋值颜色
            for color_i=2:length(Row)-1
                for color_j=round(Col1(color_i)):round(Col2(color_i))
                I_original(Row(color_i),color_j,:) = color;
                end
            end
        end
%         figure(2);imshow(I_original);
        if I_previous==I_original
            previous_flag = 1;      % previous_flag:用于判断当前图像是否与前一张一样，不一样代表有新的水泡或者没有水泡形成
        else
            previous_flag = 0;      
        end
        if I_original==I1
            I1_flag = 1;            % I1_flag:用于判断当前图像是否与原图一样，一样代表无水泡
        else
            I1_flag = 0;
        end
        if previous_flag||I1_flag
        else
            Imagebubble_num = Imagebubble_num+1;
            assignin('base',['Imagebubble',num2str(Imagebubble_num)],I_original);
%             Imagebubble = [Imagebubble,I_original];  % 第一幅为原图，后面依次存有新的水泡形成的图
%             Imagebubble_num = Imagebubble_num+1;
        end
    end
end
% for k = 1:Imagebubble_num
%             Imagebubble = eval(strcat('Imagebubble',num2str(k)));
%             figure(k);imshow(Imagebubble);
% end
%% 将每幅图的水泡区进行叠加融合，透明显示

[m,n] = size(I1(:,:,1));
Image_final = uint8(zeros(m,n,3));
w = zeros(m,n);             % 各图的权重
sum = zeros(m,n);           % 每个点的水肿图序号和
for i=1:m
    for j=1:n     
        TrueFalse = ones(1,Imagebubble_num);  % 用于判断所有图的该点是否为水泡区，不是为1，是的为0
        zero_num = 0;                           % 用于计算为0的数目
        for k=2:Imagebubble_num
            Imagebubble = eval(strcat('Imagebubble',num2str(k)));
            if Imagebubble(i,j,1)==Imagebubble(i,j,2) && Imagebubble(i,j,2)==Imagebubble(i,j,3)
                TrueFalse(1,k) = 1;
            else
                zero_num = zero_num+1;
                TrueFalse(1,k) = 0;
                sum(i,j) = sum(i,j)+k;
            end
        end
        if zero_num<=5
            w(i,j) = 0.7/4*(5-zero_num);
        else
            w(i,j) = 0;
        end
    end
end
assignin('base',['W',num2str(0)],w);
w0 = eval(strcat('W',num2str(0)));

for k=2:Imagebubble_num
    Imagebubble = eval(strcat('Imagebubble',num2str(k)));
    for i=1:m
        for j=1:n
            if Imagebubble(i,j,1)==Imagebubble(i,j,2) && Imagebubble(i,j,2)==Imagebubble(i,j,3)
                w(i,j) = 0;
            else
                w(i,j) = (1-w0(i,j))*k/sum(i,j);
            end
        end
    end
    assignin('base',['W',num2str(k-1)],w);
end

for k =1:Imagebubble_num
    Imagebubble = eval(strcat('Imagebubble',num2str(k)));
    W = eval(strcat('W',num2str(k-1)));
    for i=1:m
        for j=1:n
            Image_final1(i,j,1) = Imagebubble(i,j,1)*W(i,j);
            Image_final1(i,j,2) = Imagebubble(i,j,2)*W(i,j);
            Image_final1(i,j,3) = Imagebubble(i,j,3)*W(i,j);
        end
    end
    figure;imshow(uint8(Image_final1));
    Image_final = Image_final +Image_final1;
end