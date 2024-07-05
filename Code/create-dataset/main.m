%生成簇数不同 2~n^0.5

load('lung.mat');

maxnumClusters = floor (sqrt(size(X, 1)));% 最大聚类数目 2~根号n
numRuns = 1000; % 运行次数，即基聚类器数目

%定义缺失率 10%~90%
for missing_ratio=1:9
    Hi = cell(1, numRuns);
    idx_u= cell(1, numRuns);

    % 多次运行k-means算法并保存聚类结果
    for run = 1:numRuns
        curnumClusters=randi([2, maxnumClusters]);
        [idx, centroids] = kmeans(X, curnumClusters); % 运行k-means算法
        clusterMatrix = zeros(size(X, 1), curnumClusters);%size(X, 1) 矩阵X的行数=样例数目
        for i = 1:curnumClusters
            clusterMatrix(:, i) = (idx == i);
        end

        Hi{run}=clusterMatrix;% 将聚类结果保存到聚类结果矩阵中

        %下面进行缺失处理
        %选择随机的行
        numRows = size(Hi{run}, 1);
        selection = randperm(numRows, round(0.1 *missing_ratio* numRows));

        % 按大小对选择的行号进行排序（小的排前面） ***这一步非常重要？***
        sorted_selection = sort(selection);

        % 将所选行的值设置为0
        Hi{run}(sorted_selection, :) = 0;

        % 保存所选行的行号
        idx_u{run} = sorted_selection;
    end

    y=Y;

    % 构建MAT文件名
    filename = strcat(num2str(missing_ratio), '.mat');
    % 保存数据到MAT文件
    save(num2str(filename), 'Hi',"y","idx_u");
end
