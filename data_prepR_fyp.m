clc;
clear all;
close all;
%this is actually important
target_dir= '/Users/rebeccawilder/Desktop/first-year-project';
current_dir= pwd;

if ~strcmp(current_dir, target_dir)
    cd(target_dir)
end
addpath(genpath('/Users/rebeccawilder/Desktop/CMR/'))
if ~strcmp(pwd, '/Users/rebeccawilder/Desktop/CMR/')
    cd ('/Users/rebeccawilder/Desktop/CMR/')
end 
datafile= dir('*.mat');
load(datafile(2).name);
nsubj= unique(data.subject);
LL= data.listLength;
nsubj= unique(data.subject);
std_mat= nan(size(data.recalls(data.subject==nsubj(1) & data.session==1,:)));

ifr_mask= make_clean_recalls_mask2d(data.recalls);
for subj= 1:length(nsubj)
    %Loop through sessions
    for s= 1:7
        ifr_idx= data.session== s & data.subject== nsubj(subj);
        
        ffr_idx= data.ffr.subject== nsubj(subj) & data.ffr.session == s;
        
        %Set conditional variable for calculations if subject has
        %data for currentt session
        if sum(sum(ifr_idx))~=0
            
            %Mask needs to go here
            ifr_recall= data.recalls(ifr_idx,:);
            ifr_mask= make_clean_recalls_mask2d(ifr_recall);
            ifr_rec_itemnos= data.rec_itemnos(ifr_idx,:);
            ifr_recall(~ifr_mask)= nan;
            ifr_rec_itemnos(~ifr_mask)= nan;
            
            
            %good way to spotcheck random Ss for n NaNs; 
            %if s1-s2== 0 --> correct number of NaNs
            %size(ifr_rec_itemnos(~isnan(ifr_rec_itemnos)))-size(unique(ifr_rec_itemnos(~isnan(ifr_rec_itemnos))))
            ifr_lag= LL- ifr_recall-1;
            for add_op = 1:length(ifr_lag(1,:))
               ifr_lag(:,add_op)= ifr_lag(:,add_op)+add_op;
            end
            %Mask out ffr by rec_itemnos
            ffr_mask1= ifr_rec_itemnos(ifr_mask);
            ffr_rec_itemnos= data.ffr.rec_itemnos(ffr_idx,:);
            ffr_mask2= ismember(ffr_rec_itemnos, ffr_mask1);
            
            
            %Set ffr rec_itemnos to nan if it was not ifr and or was a
            %repeated ifr
            ffr_rec_itemnos(~(ffr_mask2 | data.ffr.recalled(ffr_idx,:)))= nan;
            ffr_mask3= make_clean_recalls_mask2d(ffr_rec_itemnos);
            ffr_rec_itemnos(~ffr_mask3)= nan;
            ffr_recall= data.ffr.sp(ffr_idx,:);
            ffr_op= data.ffr.op(ffr_idx,:);
            ffr_lag= [];
            for gffrlag= 1:length(ffr_rec_itemnos)
                if isnan(ffr_rec_itemnos(gffrlag))
                    ffr_lag(gffrlag)= nan;
                else
                    ffr_lag(gffrlag)= ifr_lag(ifr_rec_itemnos==ffr_rec_itemnos(gffrlag));
                end
            end 
                    
            ffr_lag(isnan(ffr_rec_itemnos))=nan;
            
            %not calculating ffr_lag correctly
            
            
            
            
            for ifr_lag_max= 0:max(max(ifr_lag))
                    if ifr_lag_max<LL
                        ifr_lag_idx= LL:-1:LL-(ifr_lag_max-1);
                        for ifr_sp_idx= 1:length(ifr_lag_idx)
                            lag_denom(ifr_lag_max+1, ifr_sp_idx)= sum(sum(ifr_lag== ifr_lag_max & ifr_recall== ifr_lag_idx(ifr_sp_idx)));
                        end
                    elseif ifr_lag_max== LL
                        for ifr_sp_idx= 1:LL
                            %this condition is different because 16 has the max
                            %number of output possibilities
                            lag_denom(ifr_lag_max+1,ifr_sp_idx)= sum(sum(ifr_lag==LL & ifr_recall== ifr_sp_idx));
                        end 
                    else
                        ifr_lag_idx= ifr_lag_max-LL+1:LL;
                        for ifr_sp_idx= 1:length(ifr_lag_idx)
                            lag_denom(ifr_lag_max+1, ifr_sp_idx)= sum(sum(ifr_lag==LL & ifr_recall== ifr_lag_idx(ifr_sp_idx)));
                        end
                        
                    end
            end
               
            for ffr_lag_max= 0:max(max(ffr_lag))
                    if ffr_lag_max<LL
                        ffr_lag_idx= LL:-1:LL-(ffr_lag_max-1);
                        for ffr_sp_idx= 1:length(ffr_lag_idx)
                            lag_num(ffr_lag_max+1, ffr_sp_idx)= sum(sum(ffr_lag== ffr_lag_max & ffr_recall== ffr_lag_idx(ffr_sp_idx)));
                        end
                    elseif ifr_lag_max== LL
                        for ffr_sp_idx= 1:LL
                            %this condition is different because 16 has the max
                            %number of output possibilities
                            lag_num(ffr_lag_max+1,ffr_sp_idx)= sum(sum(ffr_lag==LL & ffr_recall== ffr_sp_idx));
                        end 
                    else
                        ifr_lag_idx= ifr_lag_max-LL+1:LL;
                        for ifr_sp_idx= 1:length(ifr_lag_idx)
                            lag_denom(ifr_lag_max+1, ifr_sp_idx)= sum(sum(ifr_lag==LL & ifr_recall== ifr_lag_idx(ifr_sp_idx)));
                        end
                        
                    end
            end
            
            
        else
          
            

        end
            
            %We're only doing up to lag 20
            %make things 3 dim array take avg across subj and avg across
            %session
           
            
    end
    %c1(subj, s)= any(any(isinf(lag_num(1:20,:)./lag_denom(1:20,:))));
    %Look over by hand need to reshape by every 35 to take average of
    %sessions
   %pffr{subj}= cell2mat(session_i(~cellfun('isempty',session_i)));

    ffr_save_lag{subj,s}=ffr_lag
    ffr_save_recalled{subj, s}= ffr_mask2
            
end 






for subj = 1:length(nsubj)
    for ses= 1:length(unique(data.session))
        
        ifr_idx= data.subject==nsubj(subj) & data.session== ses;
        if ~isempty(data.recalls(ifr_idx,:))
           
            %Set up serial position col:
            %correct numel and correct num of NaNs
            ifr_sp= data.recalls(ifr_idx,:);
            rec_mask= ifr_sp>0; %mask for intrusions and misses
            ifr_sp(~rec_mask)=nan;
            ifr_sp= reshape(ifr_sp', numel(ifr_sp),1);
            ifr_sp= ifr_sp(~isnan(ifr_sp));
            
            %Set up output position col:
            %correct numel and correct num of NaNs 
            ifr_op= std_mat;
            for i = 1:length(ifr_op(1,:))
                
                ifr_op(:,i)= i;
            end
            ifr_op(~rec_mask)=nan;
            ifr_op= reshape(ifr_op', numel(ifr_op),1);
            ifr_op= ifr_op(~isnan(ifr_op));
            
            %Set up response times col: 
            %correct numel and correct num of NaNs 
            ifr_rt= data.times(ifr_idx,:);
            ifr_rt(~rec_mask)=nan;
            ifr_rt= reshape(ifr_rt', numel(ifr_rt),1);
            ifr_rt= ifr_rt(~isnan(ifr_rt));
            
            %Set up subjects ID col: 
            ifr_subj= zeros(size(ifr_sp));
            ifr_subj(:,:)= nsubj(subj);
            
            %Set up session ID col: 
            ifr_ses= zeros(size(ifr_sp));
            ifr_ses(:,:)= ses;
            
            %Set up list ID col:
            %correct numel and correct num of NaNs
            ifr_list= std_mat;
            for i = 1:length(ifr_list(:,1))
                ifr_list(i,:)= i;
            end
            ifr_list(~rec_mask)= nan;
            ifr_list= reshape(ifr_list', numel(ifr_list),1);
            ifr_list= ifr_list(~isnan(ifr_list));
            
            
            %Set up rec itemnos ID col:
            %correct numel and correct num of NaNs
            ifr_itemnos= data.rec_itemnos(ifr_idx,:);
            ifr_itemnos(~rec_mask)=nan;
            ifr_itemnos= reshape(ifr_itemnos', numel(ifr_itemnos),1);
            ifr_itemnos= ifr_itemnos(~isnan(ifr_itemnos));
            
            
                
            all_data{subj, ses}= [ifr_subj, ifr_ses, ifr_list, ifr_sp, ifr_op, ifr_rt, ifr_itemnos];
            
            %each subj-ses combination should have 141 indices to start,
            %however, with nans 
            
            
            
            
            
            
        end 
    end 
    
        
end 
    
all_data= all_data(~cellfun('isempty', all_data));
all_data= cell2mat(all_data);
%% Saving Output
%name file something similar to output function
%if statement for if file exists warning about over-writing if it does
%already exist
user_input= input('To save output type ''save''\n', 's');
if strcmp(user_input, 'save')
    savefile= input('Please title your save file, excluding suffix, e.g. ''.csv'', ''.mat''  \n' ,'s');
    savefile= [savefile, '.csv'];
    dlmwrite(savefile, all_data)
end




