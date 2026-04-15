for o = 1:14
% 奇数位置是A原子数，偶数位置是B原子数，末尾有很多0
atomic_piles = arrayAll(o,:);

% --- 第1步：剔除末尾的零 ---
% 找到最后一个非零元素的位置
last_nonzero_index = find(atomic_piles ~= 0, 1, 'last');

% 截取有效数据
atomic_piles_trimmed = atomic_piles(1:last_nonzero_index);

% --- 第2步：将堆转换为单个原子的排列 ---
% 初始化一个空数组，用于存放最终的原子排列
atomic_arrangement = [];

% 遍历处理后的数组
for i = 1:length(atomic_piles_trimmed)
    % 获取当前堆的原子数
    num_atoms = atomic_piles_trimmed(i);
    
    % 根据位置的奇偶性来判断原子类型
    if mod(i, 2) == 1 % 如果是奇数位置（A原子堆）
        % 创建 num_atoms 个0，并追加到最终数组
        atomic_arrangement = [atomic_arrangement, zeros(1, num_atoms)];
    else % 如果是偶数位置（B原子堆）
        % 创建 num_atoms 个1，并追加到最终数组
        atomic_arrangement = [atomic_arrangement, ones(1, num_atoms)];
    end
end


JinZhi64{o} = binArrayToBase64String(atomic_arrangement);

end
function hexString = binToHex(binaryArray)
% BINTOHEX Converts a binary array to a hexadecimal string.
%   HEXSTRING = BINTOHEX(BINARYARRAY) takes a binary array, where each
%   element is either 0 or 1, and converts it into a hexadecimal string.
%   The function pads the binary array with leading zeros if its length
%   is not a multiple of 4.
%
%   Example:
%   binaryArray = [1 1 1 1 0 0 1 1];
%   hexString = binToHex(binaryArray);
%   disp(hexString); % Displays 'F3'

    % 获取数组长度
    len = length(binaryArray);

    % 如果长度不是4的倍数，在前面补零
    % 例如，[1 1 0] 长度为3，需补一个0变为 [0 1 1 0]
    remainder = mod(len, 4);
    if remainder ~= 0
        padding = zeros(1, 4 - remainder);
        binaryArray = [padding, binaryArray];
        len = length(binaryArray);
    end

    % 将二进制数组分组为4位的块
    % reshape(A, m, n) 是按列排的，为了方便，这里用reshape(A, n, m)'来实现按行排
    % 例如，[1 1 1 1 0 0 1 1] -> [1 1; 1 1; 0 0; 1 1]' -> [1 1 1 1; 0 0 1 1]
    binaryGroups = reshape(binaryArray, 4, len / 4)';

    % 预分配一个单元数组来存储每个十六进制字符
    hexChars = cell(1, len / 4);

    % 将每个4位二进制组转换为对应的十六进制字符
    for i = 1:len/4
        % bin2dec 将二进制字符串转换为十进制数
        decimalValue = bin2dec(num2str(binaryGroups(i, :)));
        
        % dec2hex 将十进制数转换为十六进制字符
        hexChars{i} = dec2hex(decimalValue);
    end

    % 将所有字符连接成一个字符串
    hexString = horzcat(hexChars{:});
end

function base64String = binArrayToBase64String(binaryArray)
% binArrayToBase64String 将二进制数值数组转换为Base64字符串
%   base64String = binArrayToBase64String(binaryArray)
%   输入：
%       binaryArray - 一个包含 0 和 1 的行向量或列向量，例如 [1 0 1 1 0 1]
%   输出：
%       base64String - 对应的Base64字符串，例如 'F'

% 检查输入是否为二进制数组（只包含 0 和 1）
if ~all(ismember(binaryArray, [0 1]))
    error('输入数组必须只包含 0 或 1。');
end

% 将数组转换为行向量以简化处理
binaryArray = reshape(binaryArray, 1, []);

% Base64字符集
base64_map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

% 计算需要填充的位数，确保总长度是6的倍数
num_bits = length(binaryArray);
num_padding_bits = mod(6 - mod(num_bits, 6), 6);
paddedArray = [binaryArray, zeros(1, num_padding_bits)];

% 初始化空字符串和填充符计数
base64String = '';
num_equal_signs = num_padding_bits / 2;

% 每6位进行一次转换
for i = 1:6:length(paddedArray)
    % 截取6位二进制子数组
    subArray = paddedArray(i:i+5);
    
    % 将6位二进制数组转换为十进制数
    % 例如：[1 0 1 1 0 1] -> 1*2^5 + 0*2^4 + 1*2^3 + 1*2^2 + 0*2^1 + 1*2^0 = 32+8+4+1=45
    decimalValue = subArray * (2.^(5:-1:0))';
    
    % 使用映射表找到对应的Base64字符
    base64Char = base64_map(decimalValue + 1);
    
    % 将转换后的字符拼接到结果字符串
    base64String = [base64String, base64Char];
end

% 添加填充符 '='
base64String = [base64String, repmat('=', 1, num_equal_signs)];

end