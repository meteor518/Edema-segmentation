function output = Integrity_test(RPErow,RPEcol,RPEnum)
%% 完整性检测
% 因可能有噪声影响，故变化最大的不一定就是RPE层，故需要根据其相邻层的行距来判断，如在其前一点的邻域内保留，否则将根据前一点的值重新赋值该点
line_index = 1;                         % 用于存放线段的数量
line_num = 1;                           % 用于计数每条连续的线段的长度
line(line_index,1) = RPErow(1);         % line：第一列存每条线段起始行
line(line_index,2) = RPEcol(1);         % line：第二列存每条线段起始列

for i=2:RPEnum
    if abs(RPErow(i)-RPErow(i-1))<3
        line_num = line_num+1;
    else
        line(line_index,3) = RPErow(i-1);%line：第三列存每条线段结束行
        line(line_index,4) = RPEcol(i-1);%line：第四列存每条线段结束列
        line(line_index,5) = line_num;   %line：第五列存每条线段长度
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
% 每条线段若<70,则舍去,设为0，满足条件的存入line1矩阵
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
% 舍去的部分利用前后满足条件的线段起始坐标进行线性填充
for i=1:line1_index-1
    for j=line1(i,4):line1(i+1,2)
        RPErow(j) = round((line1(i,3)-line1(i+1,1))/(line1(i,4)-line1(i+1,2))*(j-line1(i,4))+line1(i,3));
    end
end
output = RPErow;