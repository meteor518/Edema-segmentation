function output = Integrity_test(RPErow,RPEcol,RPEnum)
%% �����Լ��
% �����������Ӱ�죬�ʱ仯���Ĳ�һ������RPE�㣬����Ҫ���������ڲ���о����жϣ�������ǰһ��������ڱ��������򽫸���ǰһ���ֵ���¸�ֵ�õ�
line_index = 1;                         % ���ڴ���߶ε�����
line_num = 1;                           % ���ڼ���ÿ���������߶εĳ���
line(line_index,1) = RPErow(1);         % line����һ�д�ÿ���߶���ʼ��
line(line_index,2) = RPEcol(1);         % line���ڶ��д�ÿ���߶���ʼ��

for i=2:RPEnum
    if abs(RPErow(i)-RPErow(i-1))<3
        line_num = line_num+1;
    else
        line(line_index,3) = RPErow(i-1);%line�������д�ÿ���߶ν�����
        line(line_index,4) = RPEcol(i-1);%line�������д�ÿ���߶ν�����
        line(line_index,5) = line_num;   %line�������д�ÿ���߶γ���
        line_index = line_index+1;
        line(line_index,1) = RPErow(i); 
        line(line_index,2) = RPEcol(i);  
        line_num = 1;
    end
    if i==RPEnum
        line(line_index,3) = RPErow(i);
        line(line_index,4) = RPEcol(i);
        line(line_index,5) = line_num; 
    end
end
% ÿ���߶���<70,����ȥ,��Ϊ0�����������Ĵ���line1����
line1_index = 0;
for i=1:line_index
    if line(i,5)<70
        line(i,:) = 0;
    else
        line1_index = line1_index+1;
        line1(line1_index,1) = line(i,1);
        line1(line1_index,2) = line(i,2);
        line1(line1_index,3) = line(i,3);
        line1(line1_index,4) = line(i,4);
    end
end
% ��ȥ�Ĳ�������ǰ�������������߶���ʼ��������������
for i=1:line1_index-1
    for j=line1(i,4):line1(i+1,2)
        RPErow(j) = round((line1(i,3)-line1(i+1,1))/(line1(i,4)-line1(i+1,2))*(j-line1(i,4))+line1(i,3));
    end
end
output = RPErow;