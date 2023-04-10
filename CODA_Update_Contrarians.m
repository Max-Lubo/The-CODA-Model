%Script for running the CODA model on a von Neumann neighbourhood extende
%to include the presence of contrarians in the population (agents who are
%influeced opposite to what they observe). Parameter c defines the
%proportion of the population that are contrarians.
clear all

para = struct('N',50,'alpha',0.55,'beta',0.55,'c',1);
maxtime = 5000000;

%Setting up initial matrices for opinion and action

lattice_opinion = zeros([para.N para.N]);
lattice_op_log = zeros([para.N para.N]);
lattice_action = zeros([para.N para.N]);
lattice_contra = ones([para.N para.N]);


%Assigning a proportion of the population, "c", as contrarians

numb_contr = floor(para.c*para.N*para.N);
x = para.N*para.N;
y = numb_contr;
out = randperm(x,y);

lattice_contra(out(:)) = -1;

        



%Assigning initial random moderate opinion values
tic
for i=1:para.N
    a = 0.4;
    b = 0.6;
    r = (b-a).*rand(para.N,1) + a;
    lattice_opinion(i,:)=r;
    
    
    
    for j=1:para.N
        lattice_op_log(i,j)=log(lattice_opinion(i,j)/(1-lattice_opinion(i,j)));
        
        
            if lattice_op_log(i,j)<0
            lattice_action(i,j)=0;
            
            else
            lattice_action(i,j)=1;
            end
        
        
            if lattice_op_log(i,j)<0
            lattice_action(i,j)=1;
            
            else
            lattice_action(i,j)=0;
            end
        
    end
end






%Plotting the initial opinion map.

figure(1)
C = lattice_action;
s = pcolor(C);
s.EdgeColor = 'none';
colormap(gray(2))
axis ij
axis square

for i=2:maxtime

 %Picking which agent to update
    r_1 = randi(para.N*para.N);  
    
   
    
    %Picking their neighbour using von Neumann neighbourhood structure
    direction = randi(4);
    if direction == 1         
        
        %North
        if r_1 - para.N <= 0
            neighbour_act_obs =lattice_action(r_1);
        else
            neighbour_act_obs = lattice_action(r_1 - para.N);     
        end
        
        %East
    elseif direction == 2                                   
            
        if mod(r_1,10) == 0
           neighbour_act_obs = lattice_action(r_1);
        else
           neighbour_act_obs = lattice_action(r_1 + 1);
        end
        
        %South       
    elseif direction == 3        
             
        if r_1 + para.N > para.N*para.N
            neighbour_act_obs = lattice_action(r_1);
        else
            neighbour_act_obs = lattice_action(r_1 + para.N);
        end 
        
        %West       
    else
        if mod(r_1-1,10) == 0
            neighbour_act_obs =lattice_action(r_1);
        else
        neighbour_act_obs = lattice_action(r_1 - 1);  
        end
    end
    

        if lattice_contra == 1
            if neighbour_act_obs == 1
                lattice_op_log(r_1) = lattice_op_log(r_1) + log(para.alpha/(1-para.beta));
            elseif neighbour_act_obs == 0
                lattice_op_log(r_1) = lattice_op_log(r_1) - log(para.beta/(1-para.alpha));                                           
            end
        
        elseif lattice_contra == -1
            if neighbour_act_obs == 1
                lattice_op_log(r_1) = lattice_op_log(r_1) - log(para.alpha/(1-para.beta));
            elseif neighbour_act_obs == 0
                lattice_op_log(r_1) = lattice_op_log(r_1) + log(para.beta/(1-para.alpha));                                           
            end
        end
    
    
    if lattice_op_log(r_1) < 0
        lattice_action(r_1) = 0;
    else
        lattice_action(r_1) = 1; 
    end
    
    
% %Plotting the final action matrix as opinion map - also allowing it to show
% %model running in real time.
%     
% figure(2)
% C = lattice_action;
% s = pcolor(C);
% s.EdgeColor = 'none';
% colormap(gray(2))
% axis ij;
% axis square;
end

figure(2)
C = lattice_action;
s = pcolor(C);
s.EdgeColor = 'none';
colormap(gray(2))
axis ij
axis square
toc


nu = log(para.alpha/(1-para.alpha));

lat_op_dist = 1/nu .* lattice_op_log;

figure(3)
histogram(lat_op_dist(:),'numbins',15,'normalization','probability')