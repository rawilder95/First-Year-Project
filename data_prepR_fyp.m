clc;
clear all;
close all;
%this is actually important
target_dir= '/Users/rebeccawilder/First-Year-Project';
current_dir= pwd;
addpath(genpath(target_dir))

ifr_lag= [];
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





for subj = 1:length(nsubj)
    for ses= 1:length(unique(data.session))
        
        ifr_idx= data.subject==nsubj(subj) & data.session== ses;
        if ~isempty(data.recalls(ifr_idx,:))
           
            %Set up serial position col:
            %correct numel and correct num of NaNs
            ifr_sp= data.recalls(ifr_idx,:);
            
            %this is separate from ifr_sp for debugging, because ifr_sp is
            %reshaped
            recall= ifr_sp;
            recall(recall<1)=nan;
            
           
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
            
            ifr_lag= [];
            %Set up lag col (actual lag spacing)
            for i = 1:length(recall(1,:))
                ifr_lag(:,i)= recall(:,i)+i-1;
            end 
            ifr_lag(isnan(recall))=nan;
            ifr_lag= reshape(ifr_lag', numel(ifr_lag),1);
            ifr_lag= ifr_lag(~isnan(ifr_lag));
            
            
            %Set up subjects ID col: 
            ifr_subj= zeros(size(ifr_sp));
            ifr_subj(:,:)= nsubj(subj);
            
            %Set up session ID col: 
            ifr_ses= zeros(size(ifr_sp));
            ifr_ses(:,:)= ses;
%             ifr_lag= LL-ifr_recall
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
            %This is also for debugging
            rec_itemnos= ifr_itemnos
            
            ifr_itemnos= reshape(ifr_itemnos', numel(ifr_itemnos),1);
            ifr_itemnos= ifr_itemnos(~isnan(ifr_itemnos));
            
            %Find out which ifr lags were ffr
            ffr_idx= data.ffr.subject== nsubj(subj) & data.ffr.session== ses;
            ffr_itemnos= data.ffr.rec_itemnos(ffr_idx,:);
            ffr_lag= ismember(ifr_itemnos, ffr_itemnos);
         
                
            all_data{subj, ses}= [ifr_subj, ifr_ses, ifr_list, ifr_itemnos, ifr_rt, ifr_sp, ifr_op, ifr_lag, ffr_lag];
            
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




