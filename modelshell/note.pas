{ A notepad like editor which is used to view and edit the driver file. The
  form consists of a memo component which displays the driver file and buttons
  to save changes made to the drivers, choose a different driver file and close
  the window. }
unit note;

{$MODE Delphi}
        
interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TFmNote }

  TFmNote = class(TForm)
    MoDrivers: TMemo;
    Panel1: TPanel;
    BtnSaveFile: TButton;
    BtnCancel: TButton;
    BtnChooseFile: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnSaveFileClick(Sender: TObject);
    procedure BtnChooseFileClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FmNote: TFmNote;

implementation

{$R *.lfm}

uses frontend, fileio;

{ Set the form title and read the driver variables from the driver file into the
  memo component. }
procedure TFmNote.FormShow(Sender: TObject);
var
 tempstring1,tempstring2: string;
 ttstring:Tstringlist;
 ll: integer;
begin
 // Make sure form is visible and fits on the screen
 with FmNote do
  begin
    if Width>Screen.WorkAreaWidth then Width:=Screen.WorkAreaWidth;
    if Height>Screen.WorkAreaHeight then Height:=Screen.WorkAreaHeight;
    if Left<Screen.WorkAreaLeft then Left:=Screen.WorkAreaLeft;
    if Top<Screen.WorkAreaTop then Top:=Screen.WorkAreaTop;
  end;

// Clear the memo component of old data
  MoDrivers.Lines.Clear;

// No driver file selected
 if driverfilename = '' then
  begin
   FmNote.Caption := 'Driver Variables - No driver file selected';
   { Add driver names and units to the memo field even if no driver file was
      specified. This allows the creation of new driver files. }
    // Time column
   tempstring1 := 'Time';
   tempstring2 := ModelDef.timeunit;
    // Driver variable columns
   for ll := 1 to ModelDef.numdrive do
     begin
      tempstring1 := tempstring1 + ', ' + drive[ll].name;
      tempstring2 := tempstring2 + ', ' + drive[ll].units;
     end;
    // Copy temporary strings to memo component.
   MoDrivers.Lines.Strings[0] := tempstring1;
   MoDrivers.Lines.Add(tempstring2);
  end
 else
  begin
   Caption := 'Driver Variables - ' + driverfilename;
   // If a driverfile was selected, read in the file
   ttstring:=Tstringlist.Create;
   try try
     MoDrivers.Lines.LoadFromFile(driverfilename);
     // Check to make sure the drivers read are consistent with the model
     ttstring.Delimiter:=',';
     ttstring.StrictDelimiter:=true;
     ttstring.DelimitedText:=MoDrivers.Lines[0];
     for ll:=1 to ModelDef.numdrive do
       begin
         tempstring1:=lowercase(trim(ttstring[ll]));
         if tempstring1 <> lowercase(drive[ll].name) then
            raise Exception.Create('Drivers in the driver file do not match model drivers.');
       end;
    finally
     if Assigned(ttstring) then FreeAndNil(ttstring);
    end;
    except
     raise;
    end;
  end;
 MoDrivers.Modified := False;
end;

procedure TFmNote.FormCreate(Sender: TObject);
begin
{$ifdef Darwin}
  BtnCancel.AnchorSideRight.Control:=Panel1;
  BtnCancel.AnchorSideRight.Side:=asrRight;
  BtnSaveFile.AnchorSideRight.Control:=BtnCancel;
  BtnSaveFile.AnchorSideRight.Side:=asrLeft;
{$endif}

end;

{ Save changes made to the drivers in the memo component. }
procedure TFmNote.BtnSaveFileClick(Sender: TObject);
begin
 FmShellMain.DlgSaveDriver.InitialDir := FmShellMain.CurrentPath;
 // Set the default filename in the save dialog box to the current driverfile
 if driverfilename <> '' then
   FmShellMain.DlgSaveDriver.FileName := driverfilename;
// If the user chooses OK in the save dialog box
 if FmShellMain.DlgSaveDriver.execute then
  begin
   // Save the driver filename from the save dialog
   Driverfilename := FmShellMain.DlgSaveDriver.filename;
   FmShellMain.DriverBox.Text:=Driverfilename;
   { Save the file. Note that this function does not use the WriteDriverFile
    procedure provided in fileio.pas. This is because it is easier to save the
    file from the memo component directly then to parse the lines in the memo
    component into individual lines and then save them. }
   MoDrivers.Lines.SavetoFile(DriverFileName);
   MoDrivers.Modified:=False;
//   NewDriverFile := False;
  end;
 FmNote.Close;
end;

{ This procedure allows the user to choose a different driverfile without having
  to exit the current form. }
procedure TFmNote.BtnChooseFileClick(Sender: TObject);
begin
 FmShellMain.ChooseDriver(FmNote);
  // Update the notepad form with the new driver variables
 formshow(BtnChooseFile);
end;

procedure TFmNote.BtnCancelClick(Sender: TObject);
begin
 if MoDrivers.Modified then
   begin
     if MessageDlg('The changes you made to the drivers are about to be lost. '
          + 'Do you want to save the driver file before proceeding?' ,
          mtWarning,[mbyes,mbno],0) = mryes then BtnSaveFileClick(BtnCancel);
   end;
// FmNote.ModalResult := mrOK;
 FmNote.Close;
end;

end.
