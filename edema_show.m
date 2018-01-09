function Image_final = edema_show(bluebar,I1)
[bm,bn] = size(bluebar);                    % bm,bn:������ɫ������Ĵ�С
[bar_value,bar_index] = sort(bluebar(:,1)); % ����ɫ����������������
barcol = 1;         % barcol:���ڽ���ɫ����תΪ��ͬ�����еľ���ʱ�������У�ͬһ�߶ȵ���ɫ������ͬ4��
barrow = 1;         % barrow:���ڽ���ɫ����תΪ��ͬ�����еľ���ʱ�������У�
for i=1:bm
    if bar_value(i)>0
        blueline(barrow,barcol:barcol+3) = bluebar(bar_index(i),1:4);   % ȡ������ĵ�һ���ߣ�blueline�����ڴ����ɨ���߸߶�����ľ���
        barstart = i;
        break
    end
end

for i=barstart+1:bm
    if bar_value(i)-bar_value(i-1) > 1    % �����ǰ��ɫ������һ�������1����ʾ������ͬһ�߶ȣ�������ָ��+4����ָ��ص�����
        barcol = barcol+4;
        barrow = 1;
        blueline(barrow,barcol:barcol+3) = bluebar(bar_index(i),1:4);
    else
        barrow = barrow+1;                 % ����ͬһ�߶ȵģ���ָ�벻�䣬��ָ��+1
        blueline(barrow,barcol:barcol+3) = bluebar(bar_index(i),1:4);
    end
end

%% �����б�ʾˮ�ݵ���ɫ�ߣ���������ɨ���߼�����߸��ݸ߶ȡ��Ƿ��ص�����Ȳ���б������������ӣ��γ�ˮ������

[blm,bln] = size(blueline);     % blueline����ɨ���д洢����ɫ�����꣬blm,blnΪblueline�ľ����С
% temp(1,:) = 0;                  % temp,temp1Ϊ����ָ�룬�����ж���������ɨ��������ɫ���Ƿ�����ͬһ��ˮ��
% temp1(1,:) = 0;

edge_point(:,1:3) = 0;          % edge_point���ڴ�����ͬһ���ݵ���������

Imagebubble1 = I1;               % Imagebubble���洢�����γ�ˮ�ݺ��ͼ��
Imagebubble_num = 1;            % Imagebubble_num������ˮ��ͼ�ĸ���
I_original = I1;
count = 0;

for j=4:4:bln           % bubbleline��ÿ���д����һ��ɨ���ߵ���Ϣ�����Բ���Ϊ4
%    j=4;
    flag = 1;           % flag�������˳�ѭ�������ҵ���һɨ��������ͬһ��ˮ�ݵ���ɫ����flag=0�����������бȽ�
    [value,index] = sort(blueline(:,j));
%      i=3;
    for i=1:blm
        flag = 1;
        point = 1;
        edge_point(:,1:3) = 0;
        I_previous = I_original;
        I_original = I1;
        if value(i)>0               % ȡÿһ��ɨ���������ߣ�����ɫ�Ŵ�С����ȡ
            count = count+1;
            temp = blueline(index(i),j-3:j);  % temp��ǰ����
            if I_barmark(temp(1),temp(2),1)==255 && I_barmark(temp(1),temp(2),3)==0
                color(1,1,1) = 255;
                color(1,1,2) = 0;
                color(1,1,3) = 10*(count-1);
            else
            % color���ڸ�ֵˮ����ʾ��ɫ
                color(1,1,2) = 200;
                color(1,1,3) = 255;
                color(1,1,1) = 10*(count-1);
            end
            blueline(index(i),j-3:j) = 0;     % ȡ��������������ɫ����ԭ�����������
            edge_point(point,1) = temp(1)-round((temp(3)-temp(2))*3/8);     % ÿ�ζ�һ���������Զ���һ���㣬�γɷ����
            edge_point(point,2:3) = round((temp(2)+temp(3))/2);
            point = point+1;
            edge_point(point,:) = temp(1:3);
            k = j+4;
            while k<=bln
                [value1,index1] = sort(blueline(:,k));
                for i1=1:blm
                    if value1(i1)>0
                        temp1 = blueline(index1(i1),k-3:k);   % ȡ����һ����С��ɫ��ŵ���
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
        % ��ֵ����Ե��⻬����
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
            % ������������ֵ��ɫ
            for color_i=2:length(Row)-1
                for color_j=round(Col1(color_i)):round(Col2(color_i))
                I_original(Row(color_i),color_j,:) = color;
                end
            end
        end
%         figure(2);imshow(I_original);
        if I_previous==I_original
            previous_flag = 1;      % previous_flag:�����жϵ�ǰͼ���Ƿ���ǰһ��һ������һ���������µ�ˮ�ݻ���û��ˮ���γ�
        else
            previous_flag = 0;      
        end
        if I_original==I1
            I1_flag = 1;            % I1_flag:�����жϵ�ǰͼ���Ƿ���ԭͼһ����һ��������ˮ��
        else
            I1_flag = 0;
        end
        if previous_flag||I1_flag
        else
            Imagebubble_num = Imagebubble_num+1;
            assignin('base',['Imagebubble',num2str(Imagebubble_num)],I_original);
%             Imagebubble = [Imagebubble,I_original];  % ��һ��Ϊԭͼ���������δ����µ�ˮ���γɵ�ͼ
%             Imagebubble_num = Imagebubble_num+1;
        end
    end
end
% for k = 1:Imagebubble_num
%             Imagebubble = eval(strcat('Imagebubble',num2str(k)));
%             figure(k);imshow(Imagebubble);
% end
%% ��ÿ��ͼ��ˮ�������е����ںϣ�͸����ʾ

[m,n] = size(I1(:,:,1));
Image_final = uint8(zeros(m,n,3));
w = zeros(m,n);             % ��ͼ��Ȩ��
sum = zeros(m,n);           % ÿ�����ˮ��ͼ��ź�
for i=1:m
    for j=1:n     
        TrueFalse = ones(1,Imagebubble_num);  % �����ж�����ͼ�ĸõ��Ƿ�Ϊˮ����������Ϊ1���ǵ�Ϊ0
        zero_num = 0;                           % ���ڼ���Ϊ0����Ŀ
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