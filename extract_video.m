
pathname = '/Users/LL/Downloads/kth/';
action = 'walking';
dataset_type = 'test'
filename_prefix = strcat('person22_',action,'_d');

filename_suffix = '_uncomp-modernized';

myRange = 1:4;

for x = 1:4
    filename = strcat(filename_prefix,int2str(x),filename_suffix);
    videoPath = strcat(pathname,'mov/',action,'/',filename,'.mov');
    disp(videoPath);
    I = VideoReader(videoPath);
    
    nFrames = I.numberofFrames;
    vidHeight =  I.Height;
    vidWidth =  I.Width;

    mov(1:nFrames) = ...
        struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
               'colormap', []);

    for k = 1:nFrames
        mov(k).cdata = read(I, k);
        mov(k).cdata = imresize(mov(k).cdata,[256,256]);
        imwrite(mov(k).cdata,[pathname,'jpg/',dataset_type,'/',action,'/',filename,'_',num2str(k),'.jpg']);
    end 
end

