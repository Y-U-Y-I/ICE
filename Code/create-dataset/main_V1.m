% %生成簇数相同

% load('Isolet.mat');
% 
% % 假设你的数据集存储在一个名为X的矩阵中，大小为164x1024
% % 聚类数目为15
% numClusters = 15;% 聚类数目
% numRuns = 100; % 运行次数，即基聚类器数目
% 
% %定义缺失率 10%~70%
% for missing_ratio=1:7
%     Hi = cell(1, numRuns);
%     idx_u= cell(1, numRuns);
% 
%     % 多次运行k-means算法并保存聚类结果
%     for run = 1:numRuns
%         [idx, centroids] = kmeans(X, numClusters); % 运行k-means算法
%         clusterMatrix = zeros(size(X, 1), numClusters);%size(X, 1) 矩阵X的行数=样例数目
%         for i = 1:numClusters
%             clusterMatrix(:, i) = (idx == i);
%         end
% 
%         Hi{run}=clusterMatrix;% 将聚类结果保存到聚类结果矩阵中
% 
%         %下面进行缺失处理
%         %选择随机的行
%         numRows = size(Hi{run}, 1);
%         selection = randperm(numRows, round(0.1 *missing_ratio* numRows));
% 
%         % 按大小对选择的行号进行排序（小的排前面） ***这一步非常重要？***
%         sorted_selection = sort(selection);
% 
%         % 将所选行的值设置为0
%         Hi{run}(sorted_selection, :) = 0;
% 
%         % 保存所选行的行号
%         idx_u{run} = sorted_selection;
%     end
% 
%     y=Y;
% 
%     % 构建MAT文件名
%     filename = strcat(num2str(missing_ratio), '.mat');
%     % 保存数据到MAT文件
%     save(num2str(filename), 'Hi',"y","idx_u");
% end
