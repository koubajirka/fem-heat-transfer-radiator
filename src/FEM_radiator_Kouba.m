clc
clear all
close all

%=========================================================/
%=========================================================/
%========MKP=MODEL=ROZLOZENI=TEPLOTY=V=CHLADICI===========/
%=========HEAT=TRANSFER=FEM=MODEL=OF=A=RADIATOR===========/
%=======================JIRI=KOUBA========================/
%========================2024/2025========================/
%=========================================================/




%---------------------------------------------------------
%=========PROBLEM=SETUP=(ADJUSTABLE=PROPERTIES)===========
%==================NASTAVITELNE=HODNOTY===================

presahelementupodstavy = 4; %pocet elementu presahujicich do stran od hlavniho tela chladice (2) ► number of elements of the radiator base that stick out from the radiator body
elementypodstavyvyska = 3; %vyska podstavy v elementech (2) ► element heigth of said base
elementytelasirka = 15; %sirka tela (bez podstavy) - ZADAVAT LICHE HODNOTY!  (9) ► element width of the radiator body (w/o the base)*
elementytelavyska = 17; %vyska tela (bez podstavy) - ZADAVAT LICHE HODNOTY! (11) ► element height of the radiator body (w/o the base)*
elementyzdrojesirka = 3; %elementova sirka zdroje - ZADAVAT LICHE HODNOTY!  (5) ► element width of the heat source*
elementyzdrojevyska = 7; %elementova vyska zdroje - ZADAVAT LICHE HODNOTY!  (7) ► element height of the heat source*

% *ONLY ODD NUMBER OF ELEMENTS VIABLE DUE TO SYMMETRY (LICHE HODNOTY JSOU POZADOVANY KVULI SYMETRII)

widthspace = 0.25; %velikost elementu na vysku (a i na sirku, widthspace=heightspace!!) (0.25) [m] ► size of the element (width and height, square element)

Temp0 = 25; %teplota okoli [°C] ► temperature of the surroundings (outer temperature)
lambda = 236; % tepelna vodivost [W/m°C](-13625) ► thermal conductivity
Q = 10000; %tepelny tok [W/(m^2)] ► heat flux

%======END=OF=SETUP=(END=OF=ADJUSTABLE=PROPERTIES)========
%==============KONEC NASTAVITELNYCH HODNOT================
%---------------------------------------------------------


heightspace = widthspace; %velikost elementu na sirku (0.25) ► width of the element (width = length)

%========================================================
%NODELIST ASSEMBLY - the list of the node coordinates
%SESTAVENI NODELISTU - seznamu souradnic jednotlivych nod
%========================================================

presahnodpodstavy = presahelementupodstavy; %pocet nod presahujicich do stran od hlavniho tela chladice ► nr. of nodes of the radiator base that stick out from the radiator body
nodypodstavyvyska = elementypodstavyvyska+1; %vyska podstavy ► node heigth of said base
nodytelavyska = elementytelavyska-1; %vyska samotneho tela (bez podstavy) - SUDE HODNOTY! ► node heigth of the radiator body (w/o the base)
nodytelasirka = elementytelasirka+1; %sirka samotneho tela - SUDE HODNOTY! ► node width of the radiator body (w/o the base)*
nodyzdrojevyska = elementyzdrojevyska-1; %pocet nod chybejicich na vysku ve zdroji - SUDE HODNOTY! ► the number of nodes missing due to them being part of the heat source (heigth)
nodyzdrojesirka = elementyzdrojesirka-1; %pocet nod chybejicich na sirku ve zdroji - SUDE HODNOTY! ► the number of nodes missing due to them being part of the heat source (width)



elementcount = 2*(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelavyska*elementytelasirka-elementyzdrojevyska*elementyzdrojesirka; %celkovy pocet elementu ► total nr. of elements
nodecount = 2*(2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+nodytelasirka*nodytelavyska-((nodyzdrojevyska)*(nodyzdrojesirka)); %celkovy pocet nod ► total nr. od nodes
NL = zeros(nodecount,2); %inicializace NodeCount ► NodeCount init.

%dolni podstava ► lower base

for i = 1:(2*presahnodpodstavy+nodytelasirka)
   for j = 1:nodypodstavyvyska
       
    NL(i+((j-1)*(2*presahnodpodstavy+nodytelasirka)),:) = [(i-1)*widthspace,(j-1)*heightspace];  
         
   end    
end    

%telo pod zdrojem ► radiator body under the heat source

for i = 1:(nodytelasirka)
   for j = 1:((nodytelavyska/2)-(nodyzdrojevyska/2))
       
    NL(i+(2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+((j-1)*(nodytelasirka)),:) = [(i)*widthspace+(presahnodpodstavy-1)*widthspace,(j)*heightspace+(nodypodstavyvyska-1)*heightspace];  
         
   end    
end

%telo kolem zdroje ► radiator body around the heat source

for i = 1:(nodytelasirka-nodyzdrojesirka)
   for j = 1:nodyzdrojevyska
       
     
    NL(i+(2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+nodytelasirka*((nodytelavyska/2)-(nodyzdrojevyska/2))+((j-1)*(nodytelasirka-nodyzdrojesirka)),:) = [(i)*widthspace+(presahnodpodstavy-1)*widthspace,(j)*heightspace+(((nodytelavyska/2)-(nodyzdrojevyska/2))+nodypodstavyvyska-1)*heightspace];  
         
    if i>((nodytelasirka/2)-(nodyzdrojesirka/2))    
    NL(i+(2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+nodytelasirka*((nodytelavyska/2)-(nodyzdrojevyska/2))+((j-1)*(nodytelasirka-nodyzdrojesirka)),:) = [(i)*widthspace+(presahnodpodstavy-1+nodyzdrojesirka)*widthspace,(j)*heightspace+(((nodytelavyska/2)-(nodyzdrojevyska/2))+nodypodstavyvyska-1)*heightspace];
    end   
    
   end    
end

%telo nad zdrojem ► radiator body above the heat source

for i = 1:(nodytelasirka)
   for j = 1:((nodytelavyska/2)-(nodyzdrojevyska/2))
       
    NL(i+(2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+((nodytelavyska/2)-(nodyzdrojevyska/2))*nodytelasirka+((j-1)*(nodytelasirka))+((nodytelasirka-nodyzdrojesirka)*(nodyzdrojevyska)),:) = [(i)*widthspace+(presahnodpodstavy-1)*widthspace,(j)*heightspace+(nodypodstavyvyska-1+((nodytelavyska/2)-(nodyzdrojevyska/2))+nodyzdrojevyska)*heightspace];  
         
   end    
end

%horni podstava ► upper base

for i = 1:(2*presahnodpodstavy+nodytelasirka)
   for j = 1:nodypodstavyvyska
       
        NL(i+(2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+((nodytelavyska)-(nodyzdrojevyska))*nodytelasirka+((j-1)*(2*presahnodpodstavy+nodytelasirka))+((nodytelasirka-nodyzdrojesirka)*(nodyzdrojevyska)),:) = [(i-1)*widthspace,(j-1)*heightspace+(nodypodstavyvyska+nodytelavyska)*heightspace];  
           
   end    
end   

NL %nodelist - kazda dvojbunka obsahuje x a y souradnice dane nody ► every double-cell contains x and y coordinates of said node (row = node#)

%================================================================¨
%ELEMENTLIST ASSEMBLY - the list of the node#s of all elems.
%SESTAVENI ELEMENTLISTU - seznamu jednotlivych nod vsech elementu
%================================================================

%(proti smeru HR) ► COUNTERCLOCKWISE - IMPORTANT!


EL = zeros(elementcount,4); %inicializace ElementListu ► ElementList init.

%dolni podstava ► lower base

for k=1:(2*presahelementupodstavy+elementytelasirka)
    for l=1:elementypodstavyvyska
        EL(k+(l-1)*(2*presahelementupodstavy+elementytelasirka),1) = k+(l-1)*(2*presahnodpodstavy+nodytelasirka);
        EL(k+(l-1)*(2*presahelementupodstavy+elementytelasirka),2) = k+(l-1)*(2*presahnodpodstavy+nodytelasirka)+1;
        EL(k+(l-1)*(2*presahelementupodstavy+elementytelasirka),3) = k+(l)*(2*presahnodpodstavy+nodytelasirka)+1;
        EL(k+(l-1)*(2*presahelementupodstavy+elementytelasirka),4) = k+(l)*(2*presahnodpodstavy+nodytelasirka);
        
    end
end

%telo pod zdrojem ► radiator body under the heat source

for k=1:elementytelasirka
    for l=1:((elementytelavyska-elementyzdrojevyska)/2)
        
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka,1) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+k+(l-2)*nodytelasirka;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka,2) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+k+(l-2)*nodytelasirka+1;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka,3) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+k+(l-1)*nodytelasirka+1;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka,4) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+k+(l-1)*nodytelasirka;
        
        
        
        
        if l==1
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka,1) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska-1)+presahnodpodstavy+k+(l-1)*(nodytelasirka+presahnodpodstavy);
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka,2) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska-1)+presahnodpodstavy+k+(l-1)*(nodytelasirka+presahnodpodstavy)+1;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka,3) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska-1)+presahnodpodstavy+k+(l)*(nodytelasirka+presahnodpodstavy)+1;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka,4) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska-1)+presahnodpodstavy+k+(l)*(nodytelasirka+presahnodpodstavy);
        end      
        
    end
end

%telo kolem zdroje ► radiator body around the heat source

for k=1:elementytelasirka-elementyzdrojesirka
    
    for l=1:elementyzdrojevyska
        
        if l==1
            
            
            
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),1) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2)-1)+k;
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),2) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2)-1)+k+1;     
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),3) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2)-1)+k+1+(nodytelasirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),4) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2)-1)+k+(nodytelasirka);
         
         if k>(elementytelasirka-elementyzdrojesirka)/2
          
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),1) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2)-1)+k+nodyzdrojesirka+1;
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),2) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2)-1)+k+nodyzdrojesirka+1+1;     
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),3) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2)-1)+k+nodyzdrojesirka+1+1+(nodytelasirka-nodyzdrojesirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),4) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2)-1)+k+nodyzdrojesirka+1+(nodytelasirka-nodyzdrojesirka);
         
     
         end
         
        end
        
        
        if l>1
        
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),1) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+(l-2)*(nodytelasirka-nodyzdrojesirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),2) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+(l-2)*(nodytelasirka-nodyzdrojesirka);     
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),3) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+(l-2)*(nodytelasirka-nodyzdrojesirka)+(nodytelasirka-nodyzdrojesirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),4) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+(l-2)*(nodytelasirka-nodyzdrojesirka)+(nodytelasirka-nodyzdrojesirka);
         
            
            
            
         if k>(elementytelasirka-elementyzdrojesirka)/2   
            
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),1) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+(l-2)*(nodytelasirka-nodyzdrojesirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),2) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+1+(l-2)*(nodytelasirka-nodyzdrojesirka);     
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),3) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+1+(l-2)*(nodytelasirka-nodyzdrojesirka)+(nodytelasirka-nodyzdrojesirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),4) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+(l-2)*(nodytelasirka-nodyzdrojesirka)+(nodytelasirka-nodyzdrojesirka);
         
         end
         
        end
        
  
        
        if l == elementyzdrojevyska
        
        EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),1) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+(l-2)*(nodytelasirka-nodyzdrojesirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),2) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+(l-2)*(nodytelasirka-nodyzdrojesirka);     
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),3) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+(l-2)*(nodytelasirka-nodyzdrojesirka)+(nodytelasirka-nodyzdrojesirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),4) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+(l-2)*(nodytelasirka-nodyzdrojesirka)+(nodytelasirka-nodyzdrojesirka);
         
     
         if k>(elementytelasirka-elementyzdrojesirka)/2   
            
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),1) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+(l-2)*(nodytelasirka-nodyzdrojesirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),2) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+1+(l-2)*(nodytelasirka-nodyzdrojesirka);     
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),3) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+1+(l-2)*(nodytelasirka-nodyzdrojesirka)+(nodytelasirka);
         EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2)+k+(l-1)*(elementytelasirka-elementyzdrojesirka),4) =(2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*(((nodytelavyska-nodyzdrojevyska)/2))+k+1+(l-2)*(nodytelasirka-nodyzdrojesirka)+(nodytelasirka);
         
         end    
    
        end 
          
        
    end
      
end

%telonadzdrojem ► radiator body above the heat source

for k=1:elementytelasirka
    for l=1:((elementytelavyska-elementyzdrojevyska)/2)
        
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka+(elementyzdrojevyska)*(elementytelasirka-elementyzdrojesirka)+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2),1) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*((nodytelavyska-nodyzdrojevyska)/2)+nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+k+(l-1)*nodytelasirka;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka+(elementyzdrojevyska)*(elementytelasirka-elementyzdrojesirka)+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2),2) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*((nodytelavyska-nodyzdrojevyska)/2)+nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+k+(l-1)*nodytelasirka+1;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka+(elementyzdrojevyska)*(elementytelasirka-elementyzdrojesirka)+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2),3) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*((nodytelavyska-nodyzdrojevyska)/2)+nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+k+(l)*nodytelasirka+1;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka+(elementyzdrojevyska)*(elementytelasirka-elementyzdrojesirka)+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2),4) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*((nodytelavyska-nodyzdrojevyska)/2)+nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+k+(l)*nodytelasirka;
        
    


        if l==((elementytelavyska-elementyzdrojevyska)/2)
            
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka+(elementyzdrojevyska)*(elementytelasirka-elementyzdrojesirka)+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2),1) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*((nodytelavyska-nodyzdrojevyska)/2)+nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+k+(l-1)*nodytelasirka;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka+(elementyzdrojevyska)*(elementytelasirka-elementyzdrojesirka)+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2),2) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*((nodytelavyska-nodyzdrojevyska)/2)+nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+k+(l-1)*nodytelasirka+1;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka+(elementyzdrojevyska)*(elementytelasirka-elementyzdrojesirka)+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2),3) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*((nodytelavyska-nodyzdrojevyska)/2)+nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+k+(l-1)*nodytelasirka+nodytelasirka+presahnodpodstavy+1;
        EL(k+(2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+(l-1)*elementytelasirka+(elementyzdrojevyska)*(elementytelasirka-elementyzdrojesirka)+elementytelasirka*((elementytelavyska-elementyzdrojevyska)/2),4) = (2*presahnodpodstavy+nodytelasirka)*(nodypodstavyvyska)+nodytelasirka*((nodytelavyska-nodyzdrojevyska)/2)+nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+k+(l-1)*nodytelasirka+nodytelasirka+presahnodpodstavy;
        
                       
        end    


        
    end
end

%horni podstava ► upper base


for k=1:(2*presahelementupodstavy+elementytelasirka)
    for l=1:elementypodstavyvyska
        EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*(elementytelavyska-elementyzdrojevyska)+(elementytelasirka-elementyzdrojesirka)*elementyzdrojevyska+k+(l-1)*(2*presahelementupodstavy+elementytelasirka),1) = (2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+(nodytelavyska-nodyzdrojevyska)*nodytelasirka+(nodytelasirka-nodyzdrojesirka)*nodyzdrojevyska+k+(l-1)*(2*presahnodpodstavy+nodytelasirka);
        EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*(elementytelavyska-elementyzdrojevyska)+(elementytelasirka-elementyzdrojesirka)*elementyzdrojevyska+k+(l-1)*(2*presahelementupodstavy+elementytelasirka),2) = (2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+(nodytelavyska-nodyzdrojevyska)*nodytelasirka+(nodytelasirka-nodyzdrojesirka)*nodyzdrojevyska+k+(l-1)*(2*presahnodpodstavy+nodytelasirka)+1;
        EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*(elementytelavyska-elementyzdrojevyska)+(elementytelasirka-elementyzdrojesirka)*elementyzdrojevyska+k+(l-1)*(2*presahelementupodstavy+elementytelasirka),3) = (2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+(nodytelavyska-nodyzdrojevyska)*nodytelasirka+(nodytelasirka-nodyzdrojesirka)*nodyzdrojevyska+k+(l)*(2*presahnodpodstavy+nodytelasirka)+1;
        EL((2*presahelementupodstavy+elementytelasirka)*elementypodstavyvyska+elementytelasirka*(elementytelavyska-elementyzdrojevyska)+(elementytelasirka-elementyzdrojesirka)*elementyzdrojevyska+k+(l-1)*(2*presahelementupodstavy+elementytelasirka),4) = (2*presahnodpodstavy+nodytelasirka)*nodypodstavyvyska+(nodytelavyska-nodyzdrojevyska)*nodytelasirka+(nodytelasirka-nodyzdrojesirka)*nodyzdrojevyska+k+(l)*(2*presahnodpodstavy+nodytelasirka);
        
    end
end

%========================================================================
%VISUALISATION (GENERATION OF NUMBERED NODES AND ELEMENTS (FOR CHECKING))
%VIZUALIZACE (OCISLOVANE ELEMENTY + NODY (PRO KONTROLU))
%========================================================================

figure
hold on
axis([-1 ((presahelementupodstavy*2+elementytelasirka)*widthspace)+1  -1 (2*elementypodstavyvyska+elementytelavyska)*heightspace+1]);
axis equal


for i=1:nodecount
plot(NL(i,1),NL(i,2),'-o','MarkerFaceColor',[0,0,0])
text(NL(i,1)+widthspace/5,NL(i,2)+heightspace/4,sprintf('%i',i),'FontSize',5)
end


for i=1:elementcount
    
        
        plot([NL(EL(i,1),1), NL(EL(i,2),1)], [NL(EL(i,1),2), NL(EL(i,2),2)],'-r')
        plot([NL(EL(i,2),1), NL(EL(i,3),1)], [NL(EL(i,2),2), NL(EL(i,3),2)],'-r')
        plot([NL(EL(i,3),1), NL(EL(i,4),1)], [NL(EL(i,3),2), NL(EL(i,4),2)],'-r')
        plot([NL(EL(i,4),1), NL(EL(i,1),1)], [NL(EL(i,4),2), NL(EL(i,1),2)],'-r')
        %plot([x1 x2],[y1 y2])
end

for i=1:elementcount
text(NL(EL(i,1),1)+widthspace/3,NL(EL(i,1),2)+heightspace/2,sprintf('%i',i),'FontSize',7,'color','r')
end

title('Vizualizace chladice + cislovani nod a elementu','Color', 'm')

%=================================================
%LIST OF NODES TO WHICH TO APPLY BOUNDARY COND. T0
%SEZNAM NOD NA KTERYCH JE POC PODM. T0:
%=================================================

j=1;
t0 = zeros();
for i=1:(2*presahnodpodstavy + nodytelasirka)
    t0(j)=i;
    j=j+1;
end

for i=1:(nodypodstavyvyska-1)
    t0(j)=(2*presahnodpodstavy + nodytelasirka)+i*(2*presahnodpodstavy + nodytelasirka); 
    j=j+1;
end

for i=1:presahelementupodstavy
    t0(j)=(2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) - i;
    j=j+1
end

for i=1:((nodytelavyska-nodyzdrojevyska)/2)
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + i*nodytelasirka;
    j=j+1;
end

for i=1:nodyzdrojevyska
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + i*(nodytelasirka-nodyzdrojesirka);
    j=j+1;
end

for i=1:((nodytelavyska-nodyzdrojevyska)/2)
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ i*(nodytelasirka);
    j=j+1;
end

t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy;
j=j+1;

for i=1:presahnodpodstavy
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + i;
    j=j+1;
end

for i=1:elementypodstavyvyska
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + i*(2*presahnodpodstavy + nodytelasirka);
    j=j+1;   
end

for i=1:((2*presahnodpodstavy + nodytelasirka)-1)
    t0(j) = (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - i;
    j=j+1;
end

for i=1:elementypodstavyvyska
    t0(j) = (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - i*(2*presahnodpodstavy + nodytelasirka);
    j=j+1;
end

for i=1:presahnodpodstavy
    t0(j) = (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) + i;
    j=j+1;
end

t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) + presahnodpodstavy - (nodytelasirka+presahnodpodstavy);
j=j+1;

for i=1:(((nodytelavyska-nodyzdrojevyska)/2)-1)
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) + presahnodpodstavy - (nodytelasirka+presahnodpodstavy) - i*nodytelasirka;
    j=j+1;
end

for i=1:nodyzdrojevyska
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) + presahnodpodstavy - (nodytelasirka+presahnodpodstavy) - (((nodytelavyska-nodyzdrojevyska)/2)-1)*nodytelasirka - i*(nodytelasirka-nodyzdrojesirka);
    j=j+1;
end

for i=1:((nodytelavyska-nodyzdrojevyska)/2)
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) + presahnodpodstavy - (nodytelasirka+presahnodpodstavy) - (((nodytelavyska-nodyzdrojevyska)/2)-1)*nodytelasirka - nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka) - i*nodytelasirka;
    j=j+1;
end

t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) + presahnodpodstavy - (nodytelasirka+presahnodpodstavy) - (((nodytelavyska-nodyzdrojevyska)/2)-1)*nodytelasirka - nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka) - ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka - (nodytelasirka+presahnodpodstavy);
j=j+1;   

for i=1:presahnodpodstavy
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) + presahnodpodstavy - (nodytelasirka+presahnodpodstavy) - (((nodytelavyska-nodyzdrojevyska)/2)-1)*nodytelasirka - nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka) - ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka - (nodytelasirka+presahnodpodstavy) - i;
    j=j+1;
end

for i=1:(nodypodstavyvyska-2)
    t0(j)= (2*presahnodpodstavy + nodytelasirka)+(nodypodstavyvyska-1)*(2*presahnodpodstavy + nodytelasirka) + ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka + nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka)+ ((nodytelavyska-nodyzdrojevyska)/2)*(nodytelasirka)+nodytelasirka+presahnodpodstavy + presahnodpodstavy + elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) - ((2*presahnodpodstavy + nodytelasirka)-1) - elementypodstavyvyska*(2*presahnodpodstavy + nodytelasirka) + presahnodpodstavy - (nodytelasirka+presahnodpodstavy) - (((nodytelavyska-nodyzdrojevyska)/2)-1)*nodytelasirka - nodyzdrojevyska*(nodytelasirka-nodyzdrojesirka) - ((nodytelavyska-nodyzdrojevyska)/2)*nodytelasirka - (nodytelasirka+presahnodpodstavy) - presahnodpodstavy - i*(2*presahnodpodstavy + nodytelasirka);
    j=j+1;
end



t0=t0';



%---------------
%===============
%HEAT TRANSFER
%VEDENI TEPLA
%===============
%---------------

K = zeros(size(NL,1),size(NL,1));
l = widthspace;

%Souradnice int. bodu
ksi(1) = 0;               eta(1) = 0;
ksi(2) = 0;               eta(2) = sqrt(3/5);
ksi(3) = sqrt(3/5);       eta(3) = 0;
ksi(4) = 0;               eta(4) = -sqrt(3/5);
ksi(5) = -sqrt(3/5);      eta(5) = 0;
ksi(6) = sqrt(3/5);       eta(6) = sqrt(3/5);
ksi(7) = sqrt(3/5);       eta(7) = -sqrt(3/5);
ksi(8) = -sqrt(3/5);      eta(8) = -sqrt(3/5);
ksi(9) = -sqrt(3/5);      eta(9) = sqrt(3/5);
% vahy
w(1) = 64/81;
w(2:1:5) = 40/81;
w(6:1:9) = 25/81;


Fe = zeros(1,4);

%elementy s OP: (ELEMENTY ZDROJE) ► THE ELEMENTS BORDERING THE HEAT SOURCE

lowerQ = zeros(elementyzdrojesirka,1);
for i=1:elementyzdrojesirka
lowerQ(i) = elementypodstavyvyska*((presahelementupodstavy*2)+elementytelasirka)+(((elementytelavyska-elementyzdrojevyska)/2)-1)*elementytelasirka + ((elementytelasirka-elementyzdrojesirka)/2) + i;
end

leftQ = zeros(elementyzdrojevyska,1);
for i=1:elementyzdrojevyska
leftQ(i) = elementypodstavyvyska*((presahelementupodstavy*2)+elementytelasirka)+(((elementytelavyska-elementyzdrojevyska)/2))*elementytelasirka + ((elementytelasirka-elementyzdrojesirka)/2) + (i-1)*(elementytelasirka-elementyzdrojesirka);
end

upperQ = zeros(elementyzdrojesirka,1);
for i=1:elementyzdrojesirka
upperQ(i) = elementypodstavyvyska*((presahelementupodstavy*2)+elementytelasirka)+(((elementytelavyska-elementyzdrojevyska)/2))*elementytelasirka + elementyzdrojevyska*((elementytelasirka-elementyzdrojesirka)) + ((elementytelasirka-elementyzdrojesirka)/2) + i;
end

rightQ = zeros(elementyzdrojevyska,1);
for i=1:elementyzdrojevyska
rightQ(i) = elementypodstavyvyska*((presahelementupodstavy*2)+elementytelasirka)+(((elementytelavyska-elementyzdrojevyska)/2))*elementytelasirka + ((elementytelasirka-elementyzdrojesirka)/2) + 1 + (i-1)*(elementytelasirka-elementyzdrojesirka);
end

lowerQ
leftQ
upperQ
rightQ

%KONEC ELEMENTU ZDROJE ► END OF THE ELEMENTS BORDERING THE HEAT SOURCE

%Nody s OP: (NODY ZDROJE) ► NODES OF THE HEAT SOURCE
lowerQnodes = zeros(nodyzdrojesirka,1);
for i=1:nodyzdrojesirka
lowerQnodes(i) = nodypodstavyvyska*((presahnodpodstavy*2)+nodytelasirka)+(((nodytelavyska-nodyzdrojevyska)/2)-1)*nodytelasirka + ((nodytelasirka-nodyzdrojesirka)/2) + i;
end

leftQnodes = zeros(nodyzdrojevyska,1);
for i=1:nodyzdrojevyska
leftQnodes(i) = nodypodstavyvyska*((presahnodpodstavy*2)+nodytelasirka)+(((nodytelavyska-nodyzdrojevyska)/2))*nodytelasirka + ((nodytelasirka-nodyzdrojesirka)/2) + (i-1)*(nodytelasirka-nodyzdrojesirka);
end

upperQnodes = zeros(nodyzdrojesirka,1);
for i=1:nodyzdrojesirka
upperQnodes(i) = nodypodstavyvyska*((presahnodpodstavy*2)+nodytelasirka)+(((nodytelavyska-nodyzdrojevyska)/2))*nodytelasirka + nodyzdrojevyska*((nodytelasirka-nodyzdrojesirka)) + ((nodytelasirka-nodyzdrojesirka)/2) + i;
end

rightQnodes = zeros(nodyzdrojevyska,1);
for i=1:nodyzdrojevyska
rightQnodes(i) = nodypodstavyvyska*((presahnodpodstavy*2)+nodytelasirka)+(((nodytelavyska-nodyzdrojevyska)/2))*nodytelasirka + ((nodytelasirka-nodyzdrojesirka)/2) + 1 + (i-1)*(nodytelasirka-nodyzdrojesirka);
end

lowerQnodes
leftQnodes
upperQnodes
rightQnodes

revupperQnodes = flipud(upperQnodes);
revleftQnodes = flipud(leftQnodes);

%KONEC NOD ZDROJE ► END OF HEAT SOURCE NODES





Fe_lowerQ = Q*[0; 0; l/2; l/2];
Fe_leftQ = Q*[0; l/2; l/2; 0 ];
Fe_upperQ = Q*[l/2; l/2; 0; 0];
Fe_rightQ = Q*[l/2; 0; 0; l/2];
F = zeros(nodecount,1);



for k = 1:size(EL,1)
% for k = 1:12
K_e = zeros(4,4);
Ke = zeros(4,4);

a = EL(k,1);
b = EL(k,2);
c = EL(k,3);
d = EL(k,4);


X_e = [NL(a,1); NL(b,1); NL(c,1); NL(d,1)];
Y_e = [NL(a,2); NL(b,2); NL(c,2); NL(d,2)];

Fe = [0;0;0;0];
if ismember(k,upperQ,'rows')== 1
   Fe = Fe_upperQ;
end
if ismember(k,leftQ,'rows')== 1
   Fe = Fe_leftQ;
end
if ismember(k,lowerQ,'rows')== 1
   Fe = Fe_lowerQ;
end
if ismember(k,rightQ,'rows')== 1
   Fe = Fe_rightQ;
end

%==================================================================
%JACOBIAN ACQUISITION + WEIGHTED RESIDUALS + GAUSS QUAD INTEGRATION
%VYPOCET JAKOBIANU + VAHY + INTEGRACE pomoci Gaussovych Kv. Vzorcu
%==================================================================

for i=1:1:9
  
    N_ksi = N_ksi_func(ksi(i), eta(i));
    N_eta = N_eta_func(ksi(i), eta(i));
    
    %vypocet J ► Jacobian Acquisition
    
    J = [N_ksi'*X_e, N_ksi'*Y_e;
         N_eta'*X_e, N_eta'*Y_e];
     inv_J = inv(J);
     
    %vypocet N_x a N_y ► N_x and N_y Acquisition
    
    N_x = inv_J(1,1)*N_ksi + inv_J(1,2)*N_eta;
    N_y = inv_J(2,1)*N_ksi + inv_J(2,2)*N_eta;
    
    %integrace ► integration
    
    Ke = w(i)*lambda*(N_x*N_x' + N_y*N_y')*abs(det(J));
    
    %lokalni matice tuhosti ► local stiffness matrix
    
    K_e = K_e + Ke;
 
end

% sestaveni globalni matice tuhosti ► global stiffness matrix assembly

je = 1:4;
curEL(je) = EL(k,je);
igl = curEL;
indexIgl = find(igl);
K(igl(indexIgl),igl(indexIgl)) = K(igl(indexIgl),igl(indexIgl)) + K_e(igl>0,igl>0);
F(igl(indexIgl)) = F(igl(indexIgl)) + Fe(igl>0);  

end


h=0;
for n = 1:size(F)
    if ismember(n,t0,'rows')== 1
     F(n) = Temp0;
    end
end   

% definovani vektoru teplot ► temp vector definition

countindex = 1;
numberindex = 1;
while countindex <= nodecount

    if ismember(numberindex,t0)
    
    numberindex=numberindex+1;
        
    end
    
    if ismember(numberindex,lowerQnodes)
    
    numberindex=numberindex+1;    
        
    end
    
    if ismember(numberindex,leftQnodes)
    
    numberindex=numberindex+1; 
        
    end
    
    if ismember(numberindex,upperQnodes)
    
    numberindex=numberindex+1;  
        
    end
    
    if ismember(numberindex,rightQnodes)
    
    numberindex=numberindex+1;
        
    end
    
    
    if ismember(numberindex,t0)==false&&numberindex<=nodecount
     if ismember(numberindex,lowerQnodes)==false
      if ismember(numberindex,leftQnodes)==false
       if ismember(numberindex,upperQnodes)==false
        if ismember(numberindex,rightQnodes)==false
    
            
            index(countindex,1)=numberindex;
            
            numberindex=numberindex+1;
            countindex=countindex+1;
        
    end
        
    end
        
    end
        
    end

    end

    
    if numberindex>=nodecount
       index(countindex:(countindex+length(t0))-1,1)=t0; 
       index((countindex+length(t0)):(countindex+length(t0))+length(lowerQnodes)-1,1)=lowerQnodes;
       index((countindex+length(t0))+length(lowerQnodes):(countindex+length(t0))+length(lowerQnodes)+length(rightQnodes)-1,1)=rightQnodes;
       index((countindex+length(t0))+length(lowerQnodes)+length(rightQnodes):(countindex+length(t0))+length(lowerQnodes)+length(rightQnodes)+length(upperQnodes)-1,1)=revupperQnodes;
       index((countindex+length(t0))+length(lowerQnodes)+length(rightQnodes)+length(upperQnodes):(countindex+length(t0))+length(lowerQnodes)+length(rightQnodes)+length(upperQnodes)+length(leftQnodes)-1,1)=revleftQnodes;
       
       countindex=1000;
    end
    

end

%PROVERIT SPRAVNOST INDEXU (KOLEM ZDROJE!!!!) ► CHECK INDEXES AROUND THE HEAT SOURCE



lent0=length(t0)+length(lowerQnodes)+length(leftQnodes)+length(upperQnodes)+length(rightQnodes);

% % prehozeni sloupcu a radku matice K ► transposition of matrix K

Knew = zeros(size(index,1),size(index,1));
Knew2 = zeros(size(index,1),size(index,1)); 
for i = 1:1:size(index,1)
Knew(:,i) = K(:,index(i));
end
for i = 1:1:size(index,1)
Knew2(i,:) = Knew(index(i),:);
end

% prehozeni vektoru F ► transposition of vector F

Fnew = zeros(size(index,1),1);
Fnew2 = zeros(size(index,1),1);
for i = 1:1:size(index,1)
Fnew(i) = F(index(i));
end

% definovani dilcich matic a vektoru OP teplot  + samotny vypocet ► submatrices definition and Temp. Bound. Cond. vector

K11 = Knew2(1:(nodecount-lent0),1:(nodecount-lent0));
K12 = Knew2(1:(nodecount-lent0),(nodecount-lent0+1):nodecount);



T2 = Fnew((nodecount-lent0+1):end,1);

Fnew(1:(nodecount-lent0)) = K11\(-K12*T2);

%srovnani vektoru zpet do spravneho poradi ► vector re-sorting

T = zeros(size(index,1),1);
for i = 1:1:size(index,1)
    for j =1:1:size(index,1)
        if(index(j) == i)
            T(i) = Fnew(j);
        end
    end
end

%=======================
% VISUALISATION/OUTPUT
% VYKRESLENI VYSLEDKU
%=======================

for i = 1:1:elementcount
    a = EL(i,1);
    b = EL(i,2);
    c = EL(i,3);
    d = EL(i,4);
    Z(i) = (T(a)+T(b)+T(c)+T(d))/4;   
end



por = zeros(elementcount,4)
for i = 1:elementcount
    
    por(i,1)=4*(i-1)+1;
    por(i,2)=4*(i-1)+2;
    por(i,3)=4*(i-1)+3;
    por(i,4)=4*(i-1)+4;
    
end

%pozice --- POSTUPNE NODY VE VSECH ELEMENTECH! ► poz --- CONTINUALLY ALL THE NODES IN ALL THE ELEMS

poz = zeros(elementcount*4,2)
for i=1:elementcount
    poz(((i-1)*4)+1,1)=NL(EL(i,1),1);
    poz(((i-1)*4)+1,2)=NL(EL(i,1),2);
    
    poz(((i-1)*4)+2,1)=NL(EL(i,2),1);
    poz(((i-1)*4)+2,2)=NL(EL(i,2),2);
    
    poz(((i-1)*4)+3,1)=NL(EL(i,3),1);
    poz(((i-1)*4)+3,2)=NL(EL(i,3),2);
    
    poz(((i-1)*4)+4,1)=NL(EL(i,4),1);
    poz(((i-1)*4)+4,2)=NL(EL(i,4),2);
end


figure
axis([-1 ((presahelementupodstavy*2+elementytelasirka)*widthspace)+1  -1 (2*elementypodstavyvyska+elementytelavyska)*heightspace+1]);
patch('Faces',por,'Vertices',poz, 'FaceVertexCData',Z','FaceColor','flat');
colorbar 
axis equal
title('Vizualizace teploty v chladici pomoci barevne mapy [°C]','Color', 'b')

 
figure

axis([-1 ((presahelementupodstavy*2+elementytelasirka)*widthspace)+1  -1 (2*elementypodstavyvyska+elementytelavyska)*heightspace+1]);
axis equal
hold on

for i = 1:size(T)
plot(NL(i,1),NL(i,2),'.','color', [(T(i,1)/(Q*widthspace)) 0 1-(T(i,1)/(Q*widthspace))],'MarkerSize',15);    
text(NL(i,1),NL(i,2)-(widthspace/4), sprintf('%3.0f',T(i,1)),'color',[0 0.5 0],'fontsize',7);



end
grid
title('Teploty v chladici v jednotlivych nodach [°C]','Color', [0.7 0 1])





%===================================================
%================FUNC=DEFINITIONS===================
%==========DEFINOVANI=POUZITYCH=FUNKCI==============
%===================================================

function N = N_func(ksi, eta)
    N = zeros(4,1);
    N(1) = (1/4)*(1 - ksi)*(1 - eta);
    N(2) = (1/4)*(1 + ksi)*(1 - eta);
    N(3) = (1/4)*(1 + ksi)*(1 + eta);
    N(4) = (1/4)*(1 - ksi)*(1 + eta);
end

function N_ksi = N_ksi_func(ksi, eta)
    N_ksi = zeros(4,1);
    N_ksi(1) = -(1/4)*(1 - eta);
    N_ksi(2) =  (1/4)*(1 - eta);
    N_ksi(3) =  (1/4)*(1 + eta);
    N_ksi(4) = -(1/4)*(1 + eta);
end

function N_eta = N_eta_func(ksi, eta)
    N_eta = zeros(4,1);
    N_eta(1) = -(1/4)*(1 - ksi);
    N_eta(2) = -(1/4)*(1 + ksi);
    N_eta(3) =  (1/4)*(1 + ksi);
    N_eta(4) =  (1/4)*(1 - ksi);
end

