    function bt_sol = bootregs(y_bt,dy_bt,y_mdlfun,dy_dx_mdlfun,...
        x0,nlsigprob,imposeconstr,chngsolver,newoptins,nboot,msgcol)
        persistent boot_countid;
        if isempty(boot_countid)
            boot_countid = 0;
        end
        boot_countid = boot_countid + 1;
        % Add Display Progress
        cprintf(msgcol,"%d",boot_countid);
        if boot_countid ~= nboot
            % refresh rate (wait time ~ 30ms)
            pause(0.02);
            fprintf(repmat('\b',1,length(num2str(boot_countid))));
        end
        %
        bt_objsse = sum((y_mdlfun - y_bt).^2) + ...
            sum((dy_dx_mdlfun - dy_bt).^2);
        nlsigprob.Objective = bt_objsse;
        bt_sol = fitnlsig(nlsigprob,x0,imposeconstr,chngsolver,newoptins);
        if boot_countid == nboot
            clear boot_countid;
        end
    end