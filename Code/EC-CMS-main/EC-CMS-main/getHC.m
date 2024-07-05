function A = getHC(X,bound)

E = X;%复制原矩阵
E(X >= bound) = 0;%选出大于阈值的设置为0，小于阈值的设置为1
A = X - E;%相减后只剩下大于阈值的元素，即高度可靠的信息