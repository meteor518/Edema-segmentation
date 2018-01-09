function [bubbleline,LTnum] = info_seg(I_right)
    [m,n] = size(I_right); 
    gray_deback = 180;      % gray_deback:���ӽ���Ŀ��ĻҶ�ֵ������ȥ����������
    gray_back = 255;        % gray_back:�����Ҷ���ֵ
    gray_obj = 205;         % gray_obj��Ŀ�����ȷ��ֵ��
    %figure;imshow(uint8(I));title('original');
   
    %% ��˹�˲�
    g = fspecial('gaussian',[5 5],5);
    I_g = imfilter(I_right,g,'replicate');  % I_g����˹�˲���ͼ��
    
    %% ����������ɢ�˲�
    niter = 60;
    lambda = 0.1;
    kappa = 60;
    option = 1;
    I_PM = anisodiff_PM(I_g,niter, kappa, lambda, option); % I_PM������������ɢ�˲���ͼ��
    %figure;imshow(uint8(I_PM));title('PM');
    %% ��ֵ�����ӽ��ڻ�ɫֵ�ļ�ΪĿ��������Ϊ��ɫ������ɫΪ��ɫ
    % ��һ�ζ�ֵ����Ϊ�˵õ�ILM��RPE���ȥ����������
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
    % ȥ�����С��200��������
    [LT,LTnum] = bwlabel(I_bw);
    S = regionprops(LT,'all');
    I_bw = ismember(LT, find([S.Area]>200));
%     figure;imshow(I_bw);title('��ֵ��');
   
    %% ������ϲ�ILM
    % ���ڶ�ֵ��ͼ��ÿ��Ѱ�ҵ�һ����ɫ���ص㣬��ΪILM��
   ILMnum = 0;
    for j=1:n
        for i=1:m
            if I_bw(i,j) == 1   % Ѱ��ÿ�е�һ�������ص㣬��ΪILM
                ILMnum = ILMnum+1;
                ILMrow(ILMnum) = i;  % ����ILM����к��е�����
                ILMcol(ILMnum) = j;            
                break
            end
        end
    end
    %% �����Լ��
    ILMrow = Integrity_test(ILMrow,ILMcol,ILMnum);
    
    J(:,:,1) = I_right;
    J(:,:,2) = I_right;
    J(:,:,3) = I_right;
    for i=1:ILMnum
        J(ILMrow(i),ILMcol(i),1) = 255;  % ��ILM����Ϊ��ɫ
        J(ILMrow(i),ILMcol(i),2) = 0;
        J(ILMrow(i),ILMcol(i),3) = 0;
    end   
%     figure;imshow(uint8(J));title('ILM');
    
    %% �ָ����²�RPE��
    % ÿ�лҶ�ֵ�仯������ǰ����һ��ΪILM��RPE�㣬���������ж�������ļ�ΪRPE��
    RPEnum = 0;
    for j=ILMcol(1):ILMcol(ILMnum)
        RPEnum = RPEnum+1;
        x1 = 1:m;
        y1 = I_PM(x1,j);
      % plot(x1,y1);hold on
        [pksmax,locmax] = findpeaks(y1);   % Ѱ��ÿ�еļ���ֵ;pksmaxΪ������ֵ������ֵ��locmax�Ǽ���ֵ��Ӧ������λ��
        MaxPks = [locmax,pksmax];
        [pksmin,locmin] = findpeaks(-y1);  % Ѱ��ÿ�еļ�Сֵ;pksminΪ����Сֵ������ֵ��locmax�Ǽ�Сֵ��Ӧ������λ��
        MinPks = [locmin,-pksmin];
      % plot(locmax,pksmax,'b+');
      % plot(locmin,-pksmin,'ro');
        Pks = [MaxPks;MinPks];             % �����м�ֵ����ͬһ����Pks
        [pks_value,pks_index] = sort(Pks(:,1));  % �����м�ֵ���������������
        pks_diff = zeros(length(pks_value),1); % pks_diff����������ڼ�ֵ��Ĳ�ֵ����һ�׵����仯�ʣ�
        
        for i=1:length(pks_value)
            if i==1
                pks_diff(i) = 0;
            else
                pks_diff(i) = Pks(pks_index(i),2)-Pks(pks_index(i-1),2);
            end
        end
        
        [pksdiff_value,pksdiff_index] = sort(pks_diff); % �Ա仯�ʽ��������ɰ׵��ڼ��仯��������λ�ü�Ϊ�ֽ�
                                                        % ���ɰ׵��ڣ��ڼ���Ϊ��ֵ���ʲ�ֵ��С��ǰ������Ϊ�仯���ģ�һ��ILM��RPE
        if Pks(pks_index(pksdiff_index(1)),1) < Pks(pks_index(pksdiff_index(2)),1)% ȡǰ�������������бȽϣ������ΪRPE�㣬����RPErow�С�RPEcol��
            RPErow(RPEnum) = Pks(pks_index(pksdiff_index(2)),1);
        else
            RPErow(RPEnum) = Pks(pks_index(pksdiff_index(1)),1);
        end
        
        RPEcol(RPEnum) = j;
    end
    %% �����Լ��
    RPErow = Integrity_test(RPErow,RPEcol,RPEnum);
    RPErow = RPErow+2;
    for i=1:RPEnum
        J(RPErow(i),RPEcol(i),1) = 255;  % ��RPE����Ϊ��ɫ
        J(RPErow(i),RPEcol(i),2) = 255;
        J(RPErow(i),RPEcol(i),3) = 0;
    end  
%     figure;imshow(uint8(J));title('RPE');
    
    %% ��I_PMͼ��ȥ�������������±�Ϊ��ɫ
    for j=1:RPEnum
        I_PM(RPErow(j):m,RPEcol(j)) = 0;   %RPE�����µı�����Ϊ��ɫ
    end
    
    for j=1:n
        for i=1:m
            if J(i,j,1)==255&&J(i,j,2)==0  %ILM�����ϵı�����Ϊ��ɫ
                for t=1:i-1
                    I_PM(t,j) = 0;
                end            
                break
            end
        end
    end    
%     figure;imshow(uint8(I_PM));title('ȥ�������I');
   
    %% ���ζ�ֵ����׼ȷ�ָ�Ŀ������ˮ��Ϊ��ɫ
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
    %% ˮ��С��40��ȥ��
    [LT,LTnum] = bwlabel(I_bw);
    S = regionprops(LT,'all');
    I_bw = ismember(LT, find([S.Area]>45));
%     figure;imshow(I_bw);title('new I_bw');
    %% �߶�С��90����Ϊ��αˮ�ݣ�ȥ��
    [LT,LTnum] = bwlabel(I_bw);
    S = regionprops(LT,'all');
    for i=1:LTnum
        for j=floor(S(i).BoundingBox(1)):floor(S(i).BoundingBox(1)+S(i).BoundingBox(3))
            if RPErow(j)-ILMrow(j)>80
%                 fprintf('��%d���߶���%d\n', i,j)
                break
            else if j==floor(S(i).BoundingBox(1)+S(i).BoundingBox(3))
                    I_bw1 = ismember(LT, find([S.Area]~=S(i).Area));
                    I_bw = I_bw & I_bw1;
                end
            end
        end
    end
    figure;imshow(I_bw);
    %% ���ϲ���ˮ�����ּ�ˮ��ӳ����Ϣ�洢������bubbleline
    % ����ˮ���±߽����RPE��߽�ľ�������
%     I_color(:,:,1) = I_right;   % I_color��ʾ���OCT��ɫ�ָ�ͼ
%     I_color(:,:,2) = I_right;
%     I_color(:,:,3) = I_right;
    [LT,LTnum] = bwlabel(I_bw);
    S = regionprops(LT,'all');
    bubbleline = zeros(LTnum,4); % bubbleline���ڴ�ˮ��ӳ����Ϣ
 % ��һ�д�ˮ�����ĸ߶ȣ������д�ˮ�����ұ߽�,�����д�flag����ǰˮ�ݷ��࣬flag=1,��ɫ���£�flag=0��ɫ����
    for k=1:LTnum
        bubbleline(k,1) = floor(S(k).Centroid(2));
        bubbleline(k,2) = floor(S(k).BoundingBox(1));
        bubbleline(k,3) = floor(S(k).BoundingBox(1)+S(k).BoundingBox(3));
        flag = false;       % false��ʾ����ˮ�ף���ɫ��true��ʾ���£���ɫ
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