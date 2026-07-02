unit Display;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, StdCtrls, Grids, TAGraph, TASeries,
  TASources, TATools, TACustomSource, TALegendPanel, TATransformations, stypes;

const
  Maxseries = 10;
  FirstRow = 3;

type
  plotarray=array[1..MaxSeries] of string;

type

  { TFmDisplayOutput }

  TFmDisplayOutput = class(TForm)
    BtnClearSeries: TButton;
    BtnCloseDisplay: TButton;
    BtnUpdateChart: TButton;
    BtnRun: TButton;
    ChartToolset1: TChartToolset;
    ChartToolset1PanClickTool1: TPanClickTool;
    ChartToolset1PanDragTool1: TPanDragTool;
    ChartToolset1ZoomClickTool1: TZoomClickTool;
    ChartToolset1ZoomDragTool1: TZoomDragTool;
    ChBAxisAutoScale: TAutoScaleAxisTransform;
    ChBAxisLogarithm: TLogarithmAxisTransform;
    ChBAxisTransforms: TChartAxisTransformations;
    CbxParameters: TCheckBox;
    CbxStates: TCheckBox;
    ChLAxisAutoScale: TAutoScaleAxisTransform;
    ChLAxisLogarithm: TLogarithmAxisTransform;
    ChLAxisTransforms: TChartAxisTransformations;
    ChOutput: TChart;
    ChOutputLineSeries1: TLineSeries;
    ChOutputLineSeries10: TLineSeries;
    ChOutputLineSeries2: TLineSeries;
    ChOutputLineSeries3: TLineSeries;
    ChOutputLineSeries4: TLineSeries;
    ChOutputLineSeries5: TLineSeries;
    ChOutputLineSeries6: TLineSeries;
    ChOutputLineSeries7: TLineSeries;
    ChOutputLineSeries8: TLineSeries;
    ChOutputLineSeries9: TLineSeries;
    EdPar1: TEdit;
    EdPar2: TEdit;
    EdPar3: TEdit;
    EdPar4: TEdit;
    EdPar5: TEdit;
    EdPar6: TEdit;
    LblPar1: TLabel;
    LblPar2: TLabel;
    LblPar3: TLabel;
    LblPar4: TLabel;
    LblPar5: TLabel;
    LblPar6: TLabel;
    LblDirections: TLabel;
    LbxSeriesSelect: TListBox;
    ListChartSource1: TListChartSource;
    ListChartSource10: TListChartSource;
    ListChartSource2: TListChartSource;
    ListChartSource3: TListChartSource;
    ListChartSource4: TListChartSource;
    ListChartSource5: TListChartSource;
    ListChartSource6: TListChartSource;
    ListChartSource7: TListChartSource;
    ListChartSource8: TListChartSource;
    ListChartSource9: TListChartSource;
    MIYScale: TMenuItem;
    MIYSelect: TMenuItem;
    MIXScale: TMenuItem;
    MIXSelect: TMenuItem;
    MIShowTable: TMenuItem;
    MIShowChart: TMenuItem;
    MIShow: TMenuItem;
    MIYaxis: TMenuItem;
    MIUpdate: TMenuItem;
    MIPrintChart: TMenuItem;
    MIXaxis: TMenuItem;
    MILoadFile: TMenuItem;
    MIClose: TMenuItem;
    MISaveOutput: TMenuItem;
    MIChart: TMenuItem;
    MmDisplay: TMainMenu;
    MIWindow: TMenuItem;
    PnlMiddle: TPanel;
    PnlParameters: TPanel;
    PnlRerun: TPanel;
    PnlTop: TPanel;
    PnlBottom: TPanel;
    RgChartValues: TRadioGroup;
    SgModelOutput: TStringGrid;
    sLblPar1: TBoundLabel;
    sLblPar2: TBoundLabel;
    SLblPar3: TBoundLabel;
    procedure BtnClearSeriesClick(Sender: TObject);
    procedure BtnCloseDisplayClick(Sender: TObject);
    procedure BtnRunClick(Sender: TObject);
    procedure BtnUpdateChartClick(Sender: TObject);
    procedure EdParKeyPress(Sender: TObject; var Key: char);
    procedure EdParExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MILoadFileClick(Sender: TObject);
    procedure MISaveOutputClick(Sender: TObject);
    procedure MIScaleClick(Sender: TObject);
    procedure UpdateChart;
    procedure lblParClick(sender: Tobject);
    procedure refreshEdPars;
    procedure cbxParamsClick(Sender: TObject);
    procedure cbxStatesClick(Sender: TObject);
    procedure MIShowChange(Sender: TObject);
    procedure MISelectAxisClick(Sender: TObject);
  private
    { private declarations }
    FFilename:String;
    FCurrentAxis:TAxis;
    FxAxis:string;
    FDisplayStep:double;
    FDisplayStyle:TDisplayStyle;
    FInitialView:Boolean;
    FNumberofSeries:integer;    // Current number of series selected
    FSeriestoPlot:plotarray;    // The list of series to be plotted
    procedure AddSeriestoPlot(ListBox: Tlistbox);
    procedure RemoveSeriestoPlot(seriesname:string);
    function GetColumnNumber(seriesname:string):integer;
    function FindTLabel(anEdit:TEdit):TLabel;
    procedure SaveAllParamValues;
 public
    { public declarations }
    FirstWrite:Boolean;
    CurrentRow: integer;
    DisplayFilename:string;
    AutoShowChart:Boolean;
    DisplayStyle:TDisplayStyle;
    property Filename:String read FFilename write FFilename;
    property CurrentAxis:TAxis read FCurrentAxis write FCurrentAxis;
    property displaystep:double read FDisplayStep write FDisplayStep;
    property xAxis:string read FxAxis write FxAxis;
    property NumberofSeries:integer read FNumberofSeries write FNumberofSeries;
    procedure FillListBox(ListBox:TListBox);
    procedure ClearSeriestoPlot(Listbox:TListBox);
    procedure WriteOutputfromMem(aFileName:string;  stime, ETime:double);
    procedure WritePurgeOutputfromMem;
    procedure ClearGrid;
    procedure StoreResults(ctime:double; var darray:drivearray; var sarray:statearray;
         var parray:processarray);

 end;

var
  FmDisplayOutput: TFmDisplayOutput;

implementation

uses math, frontend, ParamList, calculate, ReloadDlg, trouble, fileio, SeriesForm, ScaleDlg, options;
{$R *.lfm}

{ TFmDisplayOutput }

procedure TFmDisplayOutput.FormCreate(Sender: TObject);
var
  i: integer;
begin
 FInitialView := True;
 FirstWrite := True;
 chOutput.Title.Text.text := modeldef.modelname; // Chart title

 SgModelOutput.RowCount := FirstRow;
 SgModelOutput.colcount := modeldef.numdrive + modeldef.numprocess + 1;
 // don't need numstate in the above count because the derivatives are no
 // longer in the table so the count of the derivatives in numprocess takes
 // care of numstate.
 for i := 0 to SgModelOutput.colcount - 1 do SgModelOutput.cells[i,0] := inttostr(i);
 SgModelOutput.cells[0,1] := 'Time';             // Column name
 SgModelOutput.cells[0,2] := ModelDef.timeunit;   // Column units
 for i := 1 to modeldef.numdrive do         // Add drivers to stringgrid
   begin
    SgModelOutput.cells[i,1] := drive[i].name;     // Column name
    SgModelOutput.cells[i,2] := drive[i].units;    // Column units
   end;
 for i := 1 to modeldef.numstate do         // Add state variables to grid
   begin
    SgModelOutput.cells[modeldef.numdrive + i,1] := stat[i].name;   // Column name
    SgModelOutput.cells[modeldef.numdrive + i,2] := stat[i].units;  // Column units
   end;
 for i := ModelDef.numstate + 1 to modeldef.numprocess do       // Add process variables to grid
   begin
    SgModelOutput.cells[modeldef.numdrive + i,1] := proc[i].name;  // Column name
    SgModelOutput.cells[modeldef.numdrive + i,2] := proc[i].units; // Column units
   end;

 FillListBox(LbxSeriesSelect);
 FxAxis := 'Time';
// FDisplayStep := FmOptions.RunOptions.Time_step;
{ autoshowchart := false;       }
 CurrentRow := FirstRow;
 DisplayFilename := 'Memory';
 DisplayStyle:=dsChart;
 FmDisplayOutput.ActiveControl:=Lbxseriesselect;
 // Set the first column number to -999 so that Indexof doesn't find that row when searching
 SgModelOutput.cells[0,0]:=floattostr(-999);

 {$ifdef Darwin}
    LblPar1.ShowAccelChar:=False;
    LblPar1.Caption:= 'Parameter 1';
    LblPar2.ShowAccelChar:=False;
    LblPar2.Caption := 'Parameter 2';
    LblPar3.ShowAccelChar:=False;
    LblPar3.Caption := 'Parameter 3';
    LblPar4.ShowAccelChar:=False;
    LblPar4.Caption := 'Parameter 4';
    LblPar5.ShowAccelChar:=False;
    LblPar5.Caption := 'Parameter 5';
    LblPar6.ShowAccelChar:=False;
    LblPar6.Caption := 'Parameter 6';
 {$endif}
 LbxSeriesSelect.ScrollWidth:=round(2*LbxSeriesSelect.Width);
end;

procedure TFmDisplayOutput.FormResize(Sender: TObject);
var
  numcol:double;
  newwidth, newheight, newtop, newleft:integer;
  idx, idx2:integer;
begin
 if fInitialView then
  begin
   FmDisplayOutput.Height:=round(0.8*Screen.WorkAreaHeight);
   FmDisplayOutput.Width := round(0.8*Screen.WorkAreaWidth);
   fInitialView := False;
  end;
 if DisplayStyle = dsChart then
  begin
   numcol := LbxSeriesSelect.ClientWidth/(8*stringlength);  // assumes 8 units per character
   if numcol < 1 then numcol := 1;
   LbxSeriesSelect.Columns:=round(numcol);
   idx:=LbxSeriesSelect.Columns;
  end;

  with FmDisplayOutput do
   begin
    if Width>Screen.WorkAreaWidth then newWidth:=round(Screen.WorkAreaWidth) else newWidth:=Width;
    if Height>Screen.WorkAreaHeight then newHeight:=round(Screen.WorkAreaHeight) else newHeight:=Height;
    if Left<Screen.WorkAreaLeft then newLeft:=round(Screen.WorkAreaLeft) else newLeft:=Left;
    if Top<Screen.WorkAreaTop then newTop:=round(Screen.WorkAreaTop) else newTop:=Top;
    SetBounds(newLeft,newTop,newWidth,newHeight);
   end;
 idx2:=LbxSeriesSelect.ClientWidth;
end;

procedure TFmDisplayOutput.FormShow(Sender: TObject);
begin
 FmDisplayOutput.Caption := 'Model Output - File: ' + DisplayFilename;
// MessageDlg('number selected = ' + inttostr(LbxSeriesSelect.SelCount), mtInformation, [mbOK], 0);
 if DisplayStyle = dsChart then
  begin
   SgModelOutput.Visible:=False;
   PnlMiddle.Show;
   PnlTop.Show;
   fInitialView := False;
  end
 else   // Showing Data table not chart
  begin
   SgModelOutput.Visible:=True;
   PnlMiddle.Hide;
   PnlTop.Hide;
 end;
 FmDisplayOutput.FormResize(FmShellMain);
 cbxParameters.Checked := DlgReload.cbParams.Checked;
 cbxStates.Checked := DlgReload.cbState.Checked;
end;

procedure TFmDisplayOutput.MILoadFileClick(Sender: TObject);
var
  ttime:double;
  tempdrive:drivearray;
  tempstate:statearray;
  tempprocess:processarray;
begin
 tempdrive := drive;
 tempstate := stat;
 tempprocess := proc;
 ClearGrid;
 if FmShellMain.DlgOpenOutput.execute then
  if FmShellMain.DlgOpenOutput.filename <> '' then
   begin
    DisplayFilename := FmShellMain.DlgOpenOutput.filename;
    try
     OpenOutputFile(FmShellMain.DlgOpenOutput.FileName, ModelDef.numdrive, drive, ModelDef.numstate,
       stat, ModelDef.numprocess, proc, flread);
     while not eof(outfile) do
      begin
       ReadOutputFile(ttime, ModelDef.numdrive, tempdrive, ModelDef.numstate, tempstate,
        ModelDef.numprocess, tempprocess);
       StoreResults(ttime, tempdrive, tempstate, tempprocess);
      end;
    finally
     CloseOutputFile;
    end;
   end;
end;

procedure TFmDisplayOutput.MISaveOutputClick(Sender: TObject);
begin
 if DisplayFilename = 'Memory' then
  begin
    FmShellMain.ChooseOutputFile(FmDisplayOutput);
    WriteOutputfromMem(outFileName, strtofloat(SgModelOutput.Cells[0,3]),
        strtofloat(SgModelOutput.Cells[0,SgModelOutput.RowCount-4]));
  end
 else
  MessageDlg('Data already saved in file ' + DisplayFilename, mtInformation, [mbOK], 0 );
end;

procedure TFmDisplayOutput.MIScaleClick(Sender: TObject);
begin
  if (Sender as TMenuItem).Name = 'MIXScale' then
   begin
    CurrentAxis := axBottom;
   end
  else
   begin
    CurrentAxis := axLeft;
   end;
  DlgScale.ShowModal;
end;

procedure TFmDisplayOutput.MISelectAxisClick(Sender: TObject);
begin
 if (Sender as TMenuItem).Name = 'MIXSelect' then
    CurrentAxis := axBottom
 else
    CurrentAxis := axLeft;
 FmSeries.ShowModal;
end;

procedure TFmDisplayOutput.MIShowChange(Sender: TObject);
begin
 if (Sender as TMenuItem).Name = 'MIShowTable' then
   DisplayStyle := dsTable
 else
   DisplayStyle := dsChart;
 FmDisplayOutput.FormShow(Sender);
end;

procedure TFmDisplayOutput.BtnCloseDisplayClick(Sender: TObject);
begin
  FmDisplayOutput.Close;
  DlgReload.cbParams.Checked := cbxParameters.Checked;
  DlgReload.cbState.Checked := cbxStates.Checked;
end;

procedure TFmDisplayOutput.BtnRunClick(Sender: TObject);
begin
 if MessageDlg('Rerun model using current run options?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
  begin
   SaveAllParamValues;
   SgModelOutput.BeginUpdate;
   dlgReload.BtnOK.click;
   FmShellMain.btnRun.click;
   if FmTrouble.visible then FmTrouble.BringToFront;
   SgModelOutput.EndUpdate(True);
  end;
end;

procedure TFmDisplayOutput.BtnClearSeriesClick(Sender: TObject);
begin
  ClearSeriestoPlot(LbxSeriesSelect);
end;

procedure TFmDisplayOutput.BtnUpdateChartClick(Sender: TObject);
begin
 UpdateChart;
 refreshEdPars;
end;

procedure TFmDisplayOutput.EdParKeyPress(Sender: TObject; var Key: char);
begin
 if (Key = Chr(13)) then EdParExit(Sender);
end;

{ Stores the new values of the parameters in the global array, par. }
procedure TFmDisplayOutput.EdParExit(Sender: TObject);
var
 anEdit : TEdit;
 aLabel: TLabel;
 parIndex : integer;
begin
 anEdit := sender as TEdit;
 if anEdit.modified then
  begin
   aLabel:=FindTlabel(anEdit);
   if pos('Parameter',aLabel.Caption)=0 then
    begin
     parIndex := fmCalculate.getArrayIndex(vtParameter, aLabel.Caption);
     try
       par[parIndex].value := strToFloat(anEdit.text);
     except
       messageDlg('Please choose a number', mtWarning, [mbOK], 0);
       FmDisplayOutput.ActiveControl := anEdit;
     end;
    end;
 //  refreshEdPars;
  end;
end;

procedure TFmDisplayOutput.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
 BtnCloseDisplayClick(sender);
end;

procedure TFmDisplayOutput.UpdateChart;
var
 i,j,xcolumn,ycolumn:integer;
 CurrentChartSource:^TListChartSource;
begin
try
 New(CurrentChartSource);
 // Inactivate previous series
 for i := 0 to MaxSeries - 1 do Choutput.series[i].active := false;

 // Put title on Bottom Axis
 xcolumn := GetColumnNumber(xAxis);
 ChOutput.BottomAxis.Title.Caption := SgModelOutput.cells[xcolumn,1];

 // Clear the chart of previous plots
// for i:=0 to ChOutput.SeriesCount-1 do ChOutput.Series[i].Clear;
// If ChOutput.SeriesCount > 0 then ChOutput.ClearSeries;
 ChOutputLineSeries1.Clear;
 ChOutputLineSeries2.Clear;
 ChOutputLineSeries3.Clear;
 ChOutputLineSeries4.Clear;
 ChOutputLineSeries5.Clear;
 ChOutputLineSeries6.Clear;
 ChOutputLineSeries7.Clear;
 ChOutputLineSeries8.Clear;
 ChOutputLineSeries9.Clear;
 ChOutputLineSeries10.Clear;

 // Store series to plot in plotarray
 AddSeriestoPlot(LbxSeriesSelect);

 // Activate the number of series to plot.
 for i := 0 to FNumberofSeries - 1 do Choutput.series[i].active := true;

 // Check for divide by zero if relative change is selected
 if (RgChartValues.ItemIndex=1) then
  for j := 0 to FNumberofSeries - 1 do
   begin
     ycolumn := GetColumnNumber(FSeriestoPlot[j+1]);
     if (RgChartValues.ItemIndex=1) and (strtofloat(SgModelOutput.Cells[ycolumn,FirstRow]) = 0) then  // The if itemindex=1 needs to be here so that the code doesn't give the error for every series on the chart. It only needs to be corrected once.
     begin
       MessageDlg('Unable to display relative values because y0 is zero. Displaying actual values instead.', mtInformation, [mbOK], 0 );
       RgChartValues.ItemIndex:=0;
     end;
   end;

 // Add each series to the datasource.
 for j := 0 to FNumberofSeries - 1 do
   begin
    ycolumn := GetColumnNumber(FSeriestoPlot[j+1]);
    case j of
     0: begin
         CurrentChartSource^:=ListChartSource1;
         ChOutputLineSeries1.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     1: begin
         CurrentChartSource^:=ListChartSource2;
         ChOutputLineSeries2.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     2: begin
         CurrentChartSource^:=ListChartSource3;
         ChOutputLineSeries3.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     3: begin
         CurrentChartSource^:=ListChartSource4;
         ChOutputLineSeries4.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     4: begin
         CurrentChartSource^:=ListChartSource5;
         ChOutputLineSeries5.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     5: begin
         CurrentChartSource^:=ListChartSource6;
         ChOutputLineSeries6.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     6: begin
         CurrentChartSource^:=ListChartSource7;
         ChOutputLineSeries7.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     7: begin
         CurrentChartSource^:=ListChartSource8;
         ChOutputLineSeries8.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     8: begin
         CurrentChartSource^:=ListChartSource9;
         ChOutputLineSeries9.Title := SgModelOutput.Cells[ycolumn,1];
        end;
     9: begin
         CurrentChartSource^:=ListChartSource10;
         ChOutputLineSeries10.Title := SgModelOutput.Cells[ycolumn,1];
        end;
    end;
    for i := FirstRow to SgModelOutput.RowCount - 1 do
     begin
      case RgChartValues.ItemIndex of
         0: CurrentChartSource.add(strtofloat(SgModelOutput.Cells[xcolumn,i]),
              strtofloat(SgModelOutput.Cells[ycolumn,i]));
         1: CurrentChartSource.add(strtofloat(SgModelOutput.Cells[xcolumn,i]),
              strtofloat(SgModelOutput.Cells[ycolumn,i])/strtofloat(SgModelOutput.Cells[ycolumn,FirstRow]));
         2: CurrentChartSource.add(strtofloat(SgModelOutput.Cells[xcolumn,i]),
              strtofloat(SgModelOutput.Cells[ycolumn,i])-strtofloat(SgModelOutput.cells[ycolumn,FirstRow]));
      end;
     end;
   end;
 refreshEdPars;
finally
 Dispose(CurrentChartSource);
end;
end;

procedure TFmDisplayOutput.FillListBox(ListBox:TListBox);
var
 i:integer;
begin
 ListBox.Items.Clear;
 ListBox.Items.Add('Time');
 for i := 1 to ModelDef.numdrive do   // Add driver names to listbox
  ListBox.Items.Add(drive[i].name);
 for i := 1 to ModelDef.numstate do   // Add state variable names to listbox
  ListBox.Items.Add(stat[i].name);
 for i := ModelDef.numstate + 1 to ModelDef.numprocess do // Add process variable names to listbox
  ListBox.Items.Add(proc[i].name);
end;

// Adds a series to the FSeriestoPlot array
procedure TFmDisplayOutput.AddSeriestoPlot(ListBox: Tlistbox);
var
 index:integer;
begin
  FNumberofSeries := 0;
  for index := 0 to Listbox.Items.Count - 1 do
    begin
     if Listbox.Selected[index] then
      begin
       if FNumberofSeries = MaxSeries then
          MessageDlg('Cannot display series. Maximum is 10 series.', mtError, [mbOK], 0)
       else
         begin
          FNumberofSeries := FNumberofSeries + 1;
          FSeriestoPlot[FNumberofSeries] := ListBox.Items[index];
         end;
      end;
    end;
end;

// Removes a series from the FSeriestoPlot array
procedure TFmDisplayOutput.RemoveSeriestoPlot(seriesname:string);
var
 temparray:plotarray;
 i,index:integer;
begin
  index := 1;
  temparray := FSeriestoPlot;
  for i := 1 to FNumberofSeries do
   begin
     if temparray[i] = seriesname then
       index := i;
   end;
  for i := index to FNumberofSeries - 1 do
   begin
     FSeriestoPlot[i] := temparray[i + 1];
   end;
  FNumberofSeries := FNumberofSeries - 1;
end;

// Clears the selections in a TListbox
procedure TFmDisplayOutput.ClearSeriestoPlot(Listbox:TListBox);
var
  i:integer;
begin
  for i := 0 to Listbox.Items.Count - 1 do
    begin
     if Listbox.Selected[i] then
      begin
       RemoveSeriestoPlot(Listbox.Items[i]);
       Listbox.Selected[i] := False;
      end;
    end;
end;

// Clear old data from the StringGrid to prevent data overlap when new data is added.
procedure TFmDisplayOutput.ClearGrid;
var
 i,j:integer;
begin
 for i := FirstRow to SgModelOutput.RowCount - 1 do
   for j := 0 to SgModelOutput.ColCount - 1 do
    SgModelOutput.Cells[j,i] := ''; // Set all cells to empty strings
 SgModelOutput.RowCount := FirstRow; // Decrease size of grid
 CurrentRow := FirstRow;
end;

// Get the stringgrid column number for the variable in seriesname
function TFmDisplayOutput.GetColumnNumber(seriesname:string):integer;
var
  j,num:integer;
begin
  num := -1;
  for j := 0 to SgModelOutput.Colcount - 1 do
   begin
    if SgModelOutput.Cells[j,1] = seriesname then num := j;
   end;
  GetColumnNumber := num;
end;

procedure TFmDisplayOutput.lblParClick(sender: Tobject);
var
 aLabel:Tlabel;
 anEdit:TEdit;
 idx:integer;
begin
{// Getting the number of the label, i.e. 1, 2, 3, or 4 so fmParamList knows which label/edit to modify
 tempName := (sender as tcontrol).name;
 delete(tempName, 1, 6);
 fmParamList.whichEdparselected := strToInt(tempName);     }
 aLabel:=Sender as TLabel;
 fmParamList.showmodal;
 if fmParamList.ParSelectSuccess then
  begin
   aLabel.Caption:=fmParamList.ParSelected;
   idx:=fmCalculate.GetArrayIndex(vtParameter,fmParamList.ParSelected);
   anEdit:=aLabel.FocusControl as TEdit;
   anEdit.Text:=floattostr(par[idx].value);
  end;
end;

{ Updates the parameter value shown in the maskedit. }
procedure TFmDisplayOutput.refreshEdPars;
var
 anEdit:tEdit;
 aLabel:Tlabel;
 i : integer;
 parIndex:integer;
 temp:string;
begin
 with PnlParameters do
  begin
   for i := 0 to controlCount-1 do //look at all the LabeledEdits
    begin
     if controls[i] is TEdit then
      begin
       anEdit:=controls[i] as TEdit;
       aLabel:=FindTlabel(anEdit);
       if pos('Parameter', aLabel.Caption) = 0 then
          begin
           parIndex := fmCalculate.getArrayIndex(vtParameter, aLabel.Caption);
           anEdit.Text := floatToStr(par[parIndex].value);
          end;
      end;
    end;
  end;
end;

procedure TFmDisplayOutput.cbxParamsClick(Sender: TObject);
begin
 DlgReload.CbParams.Checked:=cbxParameters.Checked;
end;

procedure TFmDisplayOutput.cbxStatesClick(Sender: TObject);
begin
 DlgReload.cbState.Checked:=cbxStates.Checked;
end;

procedure TFmDisplayOutput.WriteOutputfromMem(aFileName:string; stime, ETime:double);
var
  i, j, sRow, eRow:integer;
  tempstring: string;
  outfile: textfile;
  StartTime, EndTime: string;
begin
  StartTime:=floattostr(Stime);
  EndTime:=floattostr(eTime);
  assignfile(outfile, aFileName);
  if (FmOptions.RunOptions.AppendOutputFile) and (not FirstWrite) then
   append(outfile)
  else
   begin
    rewrite(outfile);    // Create a new file
    for j := 1 to 2 do    // Start at 1 to skip column numbers, Write names and units
      begin
        tempstring := SgModelOutput.Cells[0, j];
        for i := 1 to SgModelOutput.ColCount - 1 do tempstring := tempstring + ', ' + SgModelOutput.Cells[i, j];
        writeln(outfile, tempstring);
      end;
   end;
  try
    // Write data
    if (strtofloat(StartTime)=Time_Start) and (strtofloat(EndTime)=Time_Stop) then
     begin
      sRow:=3;
      eRow:=SgModelOutput.RowCount-1;
     end
    else
     begin
      sRow:=SgModelOutput.Cols[0].IndexOf(StartTime); // Indexof searches ALL row, including the fixed row which contains a
  //    if StartTime=Time_Start then sRow=sRow-1; // To get the initial model conditions.
      eRow:=SgModelOutput.Cols[0].IndexOf(EndTime);
     end;
    for j := sRow to eRow do
      begin
        tempstring := SgModelOutput.Cells[0, j];
        for i := 1 to SgModelOutput.ColCount - 1 do tempstring := tempstring + ', ' + SgModelOutput.Cells[i, j];
        writeln(outfile, tempstring);
      end;
  finally
    closefile(outfile);
  end;
end;

procedure TFmDisplayOutput.WritePurgeOutputfromMem;
var
  i, j:integer;
  tempstring: string;
  outfile: textfile;
begin
  assignfile(outfile, outfilename);
  try
  if FirstWrite then
   begin
    rewrite(outfile);    // Create a new file
      for j := 1 to SgModelOutput.RowCount - 1 do    // Start at 1 to skip column numbers
        begin
          tempstring := SgModelOutput.Cells[0, j];
          for i := 1 to SgModelOutput.ColCount - 1 do tempstring := tempstring + ', ' + SgModelOutput.Cells[i, j];
          writeln(outfile, tempstring);
        end;
    FirstWrite := False;
   end
  else
   begin
    append(outfile);    // Open existing file for writing
      for j := 3 to SgModelOutput.RowCount - 1 do    // Start at 3 to skip column numbers and variable names and units
        begin
          tempstring := SgModelOutput.Cells[0, j];
          for i := 1 to SgModelOutput.ColCount - 1 do tempstring := tempstring + ', ' + SgModelOutput.Cells[i, j];
          writeln(outfile, tempstring);
        end;
   end;
  ClearGrid;
  finally
    closefile(outfile);
  end;
end;

procedure TFmDisplayOutput.StoreResults(ctime:double; var darray:drivearray; var sarray:statearray;
         var parray:processarray);
var
 j: integer;
begin
 SgModelOutput.rowcount := SgModelOutput.rowcount + 1;
 SgModelOutput.Cells[0,currentrow] := format('%g',[ctime]); // Write time
 for j:= 1 to ModelDef.numdrive    // Write drivers
  do SgModelOutput.Cells[j,currentrow] := format('%.8g',[darray[j].value]);

 for j:= 1 to ModelDef.numstate    // Write state variables
  do SgModelOutput.Cells[ModelDef.numdrive + j,currentrow]
             := format('%.8g',[sarray[j].value]);
 for j:= ModelDef.numstate + 1 to ModelDef.numprocess  // Write process variables
  do SgModelOutput.Cells[ModelDef.numdrive + j, currentrow]
             := format('%.8g',[parray[j].value]);
 currentrow := currentrow + 1;
 if SgModelOutput.RowCount>=100000 then
  begin
   WritePurgeOutputFromMem;
   FmShellMain.LargeOutput := True;
  end;
end;

{ Find the matching label for the edit box.}
function TFmDisplayOutput.FindTLabel(anEdit:TEdit):TLabel;
var
 aLabel:Tlabel;
 idx:integer;
begin
 idx:=anEdit.Tag;
 case anEdit.Tag of
  1: aLabel:=LblPar1;
  2: aLabel:=LblPar2;
  3: aLabel:=LblPar3;
  4: aLabel:=LblPar4;
  5: aLabel:=LblPar5;
  6: aLabel:=LblPar6;
 end;
 FindTlabel:=aLabel;
end;

{ Check all the parameter edit boxes and read the new values. Mainly for Mac in case the user didn't hit return.}
procedure TFmDisplayOutput.SaveAllParamValues;
var
 idx, parIndex:integer;
 anEdit:TEdit;
 aLabel:TLabel;
begin
 with PnlParameters do
  begin
   for idx := 0 to controlCount-1 do //look at all the LabeledEdits
    begin
     if controls[idx] is TEdit then
      begin
       anEdit:=controls[idx] as TEdit;
       if anEdit.Modified then
        begin
         aLabel:=FindTlabel(anEdit);
         if pos('Parameter', aLabel.Caption) = 0 then
           begin
            parIndex := fmCalculate.getArrayIndex(vtParameter, aLabel.Caption);
            par[parIndex].value:=strtofloat(anEdit.Text);
           end;
        end;
      end;
    end;
  end;
end;

end.

