clear;close all;clc;

% Gerando valores iniciais
trainSize = 800;
centers = 10;
sigma = 0.05;
maxCenters = 150;
maxSigma = 0.5;
bestFold = [10000, 0, 0];

% Gerando pontos de 1 a 10 do X do Seno
X = 0.01:0.01:10;
X = X';

% Gerando o Seno de 2x
Y1 = sin(2*X);
Y1 = Y1';

% Adicionando R�ido ao seno
nValue = 0.3;
noise = nValue*randn(1, length(Y1)) - nValue/2;
Y2 = Y1 + noise;
Y2 = Y2';

% Randomizando pontos
XY = [X Y2];
XY = XY(randperm(size(XY,1)),:);

%separando dados em treino(800 amostras) e teste(200 amostras)
dados = XY;
train = dados(1:trainSize,1);
trainResult = dados(1:trainSize,2);
test = dados(trainSize+1:size(dados,1),1);
testResult = dados(trainSize+1:size(dados,1),2);
X = train;
Y2 = trainResult;
dataRight = [X Y2];

for gridCenter = centers : 10 : maxCenters
    %selecionando os centros aleatoriamente
    inds =randperm(length(X));
    c_inds = inds(1:gridCenter);
    c = X(c_inds, 1);
    for gridSigma = sigma : 0.05 : maxSigma
        
        % Criando folds
        sizeFold = size(dataRight,1)/5;
        for i = 1 : 5
            fold(i,:,:) = dataRight( sizeFold*(i-1)+1 : sizeFold*i,:);
        end
        
        mediaFold = 0;
        
        for folds = 1 : 5
            removedFold = folds;
            
            % Usando folds escolhidos para treino
            H = [];
            Yfold = [];
            Xfold = [];
            
            HR = [];
            
            testFold = fold(removedFold,:,1);
            yTestFold = fold(removedFold,:,2);
            
            for j = 1 : size(fold,1)
                %fold removido n�o � adicionado aos vetores de treinamento
                if j ~= removedFold
                    %Fun��o gaussiana utilizando como parametro o X do fold
                    %de treino, para transform�-la numa matriz de dimens�o
                    %maior H
                    for i = 1 : size(fold,2)
                        h = exp(-1/2*(repmat(fold(j,i,1), length(c), 1) - c).^2/gridSigma.^2);
                        H = [H; h'];
                        
                    end
                    % X e Y de apenas os folds selecionados
                    Yfold = [Yfold fold(j,:,2)];
                    Xfold = [Xfold fold(j,:,1)];
                else
                    %Fun��o gaussiana utilizando como parametro o X do fold
                    %removido, para transform�-la numa matriz de dimens�o
                    %maior HR
                    for i = 1 : size(fold,2)
                        h = exp(-1/2*(repmat(fold(j,i,1), length(c), 1) - c).^2/gridSigma.^2);
                        HR = [HR; h'];
                    end
                end
                
            end
            
            %Calculando W
            bias = repmat(-1,length(H),1);
            H = [bias H];
            W = (inv((H'*H))*H')*Yfold';
            
            %Testando no fold removido
            bias2 = repmat(-1,length(HR),1);
            HR = [bias2 HR];
            Y3 = W'*HR';
            
            %calculando erro do teste do fold
            erro = yTestFold-Y3;
            MSE = (erro*erro')^0.5/size(fold(removedFold,:,1),2);
            mediaFold = mediaFold+MSE;
        end
        mediaFold = mediaFold/5;

        if bestFold(1) > mediaFold
            bestFold = [mediaFold, gridSigma, gridCenter];
        end
    end
end
%selecionando centros de acordo com a melhor quantidade obtida pelo Grid
%Search
inds =randperm(length(X));
c_inds = inds(1:bestFold(3));
c = X(c_inds, 1);
H = [];
for i = 1 : length(train)
    h = exp(-1/2*(repmat(train(i,:), length(c), 1) - c).^2/bestFold(2).^2);
    H = [H; h'];
end

%Calculando W 
bias = repmat(-1,length(H),1);
H = [bias H];
W = (inv((H'*H))*H')*trainResult;

saidaTR = W'*H';
saidaTR = saidaTR';

plot(train,trainResult,'r*');
hold on;
plot(train,saidaTR, 'b*');
hold off;

%redimensionando o vetor X para um vetor H de outra dimens�o
H1 = [];
for i = 1 : length(test)
    h = exp(-1/2*(repmat(test(i,:), length(c), 1) - c).^2/bestFold(2).^2);
    H1 = [H1; h'];
end

%adicionando o bias e calculando a sa�da do teste
bias = repmat(-1,length(H1),1);
H1 = [bias H1];
Y = W'*H1';
Y = Y';
plot(test,testResult,'r*');
hold on;
plot(test,Y, 'b*');