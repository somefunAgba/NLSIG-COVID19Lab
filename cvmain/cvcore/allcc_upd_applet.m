function allcc_upd_applet(app)
app.StatusLabel.Text = "Querying ...";
app.StatusLabel.FontColor = [0.9, 0.5, 0.5];
[~,~,~] = get_cdata_applet(app,"ALL",1);
end