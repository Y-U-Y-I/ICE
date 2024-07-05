function CA = getCA(baseClsSegs,M)
CA = baseClsSegs' * baseClsSegs / M;%计算传统CA矩阵