clear; clc;
rng(42);

% Veri setlerini oluþtur
egitimset = randi([-5,5], 75, 2);
testset = randi([-5,5], 50, 2);
egitim_y = zeros(75, 1);
sutun_sayisi = size(egitimset, 1);

% Eðitim etiketlerini hesapla
for i = 1:sutun_sayisi
    x1 = egitimset(i, 1);
    x2 = egitimset(i, 2);
    egitim_y(i) = BM_20_066Rosen([x1, x2]);
end

% Eðitim verilerini birleþtir
egitimyli = [egitimset egitim_y];
test_y = zeros(50, 1);

% Test etiketlerini hesapla
for i = 1:size(testset, 1)
    x1 = testset(i, 1);
    x2 = testset(i, 2);
    test_y(i) = BM_20_066Rosen([x1, x2]);
end

% Test verilerini birleþtir
testyli = [testset test_y];
pop_uz = 5;
krom_uz = 16;

% Ýlk iterasyon
pop = randi([1,5], pop_uz, krom_uz);
mse_fitness = zeros(pop_uz, 1);

for i = 1:pop_uz
    tempFis = readfis('BM_20_066MyFis.fis');
    
    % Öncül
    tempFis.input(1).mf(1).params = pop(i,1:2); % X1 girisinin A1 üyelik fonksiyonu
    tempFis.input(1).mf(2).params = pop(i,3:4); % X1 girisinin A2 üyelik fonksiyonu
    tempFis.input(1).mf(3).params = pop(i,5:6); % X1 girisinin A3 üyelik fonksiyonu
    
    tempFis.input(2).mf(1).params = pop(i,7:8); % X2 girisinin B1 üyelik fonksiyonu
    tempFis.input(2).mf(2).params = pop(i,9:10); % X2 girisinin B2 üyelik fonksiyonu

    % Soncul
    tempFis.output(1).mf(1).params = pop(i,11); 
    tempFis.output(1).mf(2).params = pop(i,12); 
    tempFis.output(1).mf(3).params = pop(i,13);  
    tempFis.output(1).mf(4).params = pop(i,14);
    tempFis.output(1).mf(5).params = pop(i,15);  
    tempFis.output(1).mf(6).params = pop(i,16);
    
    y_sapka = evalfis(egitimset, tempFis);
    mse_fitness(i, 1) = mean((egitim_y - y_sapka).^2);
end


fuzzy(tempFis);
myfis = readfis("BM_20_066Myfis.fis");
anfis = readfis("BM_20_066Anfis.fis");
y_myfis_sapka = evalfis(testset, myfis);
y_anfis_sapka = evalfis(testset, anfis);


% Ýkinci iterasyon
for j = 1:2 % 2 iterasyon
    for i = 1:pop_uz
        % Seçme
        secilen_indeks = BM_20_066Rulettekerlegi(mse_fitness);
        secilen_kromozom = pop(secilen_indeks, :);

        % Çaprazlama
        caprazlama_orani = 0.8;
        caprazlama_indeksleri = rand(1, krom_uz) < caprazlama_orani;
        yeni_kromozom = pop(i, :);
        yeni_kromozom(caprazlama_indeksleri) = secilen_kromozom(caprazlama_indeksleri);
        
        
        % Mutasyon
        mutasyon_orani = 0.1;
        mutasyon_indeksleri = rand(1, krom_uz) < mutasyon_orani;
        yeni_kromozom(mutasyon_indeksleri) = rand(1, sum(mutasyon_indeksleri));

        % Yeni kromozomu popülasyona ekle
        pop(i, :) = yeni_kromozom;

        % Fitness hesapla
        tempFis = readfis('BM_20_066MyFis.fis');
        tempFis.input(1).mf(1).params = yeni_kromozom(1:2);
        tempFis.input(1).mf(2).params = yeni_kromozom(3:4);
        tempFis.input(1).mf(3).params = yeni_kromozom(5:6);
        tempFis.input(2).mf(1).params = yeni_kromozom(7:8);
        tempFis.input(2).mf(2).params = yeni_kromozom(9:10);
        tempFis.output(1).mf(1).params = yeni_kromozom(11); 
        tempFis.output(1).mf(2).params = yeni_kromozom(12); 
        tempFis.output(1).mf(3).params = yeni_kromozom(13);  
        tempFis.output(1).mf(4).params = yeni_kromozom(14);
        tempFis.output(1).mf(5).params = yeni_kromozom(15);  
        tempFis.output(1).mf(6).params = yeni_kromozom(16);
        
        y_myga_sapka = evalfis(egitimset, tempFis);
        mse_fitnessGA(i, 1) = mean((egitim_y - y_sapka).^2);
    end
end
%fuzzy(tempFis)
myga = readfis('BM_20_066MyFis.fis');
y_myga = evalfis(testset,tempFis);

% Gerçek ve MyFis için scatter grafiði ve eðim çizgisi
figure;

% MyFis için scatter grafiði
subplot(2, 1, 1);
scatter(test_y, y_myfis_sapka);
hold on;
xlabel('Gerçek Deðerler');
ylabel('Tahmin Edilen Deðerler');
title('MyFis Ýçin Scatter Grafiði');

% Eðim çizgisi
p1 = polyfit(test_y, y_myfis_sapka, 1);
y_fit1 = polyval(p1, test_y);
plot(test_y, y_fit1, 'r--', 'LineWidth', 2);

% R2 deðeri
r_squared_myfis = 1 - sum((y_myfis_sapka - y_fit1).^2) / sum((y_myfis_sapka - mean(y_myfis_sapka)).^2);
text(min(test_y), max(y_myfis_sapka), ['R^2 = ' num2str(r_squared_myfis)], 'HorizontalAlignment', 'left');

% Gerçek ve Anfis için scatter grafiði ve eðim çizgisi
subplot(2, 1, 2);
scatter(test_y, y_anfis_sapka);
hold on;
xlabel('Gerçek Deðerler');
ylabel('Tahmin Edilen Deðerler');
title('Anfis Ýçin Scatter Grafiði');

% Eðim çizgisi
p2 = polyfit(test_y, y_anfis_sapka, 1);
y_fit2 = polyval(p2, test_y);
plot(test_y, y_fit2, 'r--', 'LineWidth', 2);

% R2 deðeri
r_squared_anfis = 1 - sum((y_anfis_sapka - y_fit2).^2) / sum((y_anfis_sapka - mean(y_anfis_sapka)).^2);
text(min(test_y), max(y_anfis_sapka), ['R^2 = ' num2str(r_squared_anfis)], 'HorizontalAlignment', 'left');
%fuzzy(tempFis);