unit ParamList;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls;

type

  { TFmParamList }

  TFmParamList = class(TForm)
    btnCancel: TButton;
    btnSelect: TButton;
    lbParamNames: TListBox;
    lbParamSymbols: TListBox;
    PnlListBoxes: TPanel;
    PnlButtons: TPanel;
    rbParameterName: TRadioButton;
    rbParameterSymbol: TRadioButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rbParameterSymbolClick(Sender: TObject);
    procedure rbParameterNameClick(Sender: TObject);
    procedure lbParamSymbolsClick(Sender: TObject);
    procedure lbParamNamesClick(Sender: TObject);
  private
    { Private declarations }
  public
    whichEdparselected: integer;
    ParSelected: string;
    ParSelectSuccess: Boolean;
    { Public declarations }
  end;

var
  FmParamList: TFmParamList;

implementation
uses frontend, Display, calculate, stypes;
{$R *.lfm}

procedure TFmParamList.FormCreate(Sender: TObject);
var
 i : integer;
begin
{$ifdef Darwin}
  BtnCancel.AnchorSideRight.Control:=PnlButtons;
  BtnCancel.AnchorSideRight.Side:=asrRight;
  BtnSelect.AnchorSideRight.Control:=BtnCancel;
  BtnSelect.AnchorSideRight.Side:=asrLeft;
{$endif}

 // fill the boxes with names and symbols
 for i := 1 to modelDef.numparam do begin
  lbParamSymbols.Items.Add(par[i].symbol);
  lbParamNames.Items.Add(par[i].name);
 end;
 // select the first in the list
 lbParamSymbols.ItemIndex := 0;
 lbParamNames.ItemIndex := 0;

 // make sure the symbols box is on top
 lbParamSymbols.visible := true;
 lbParamNames.visible := false;
 ParSelectSuccess:=False;
end;

procedure TFmParamList.btnSelectClick(Sender: TObject);
var
 tempString : string;
 tempIndex : integer;
 ParAlreadySelected:Boolean;
begin
ParAlreadySelected:=False;
ParSelectSuccess:=False;
ParSelected:='';
tempString := lbParamSymbols.items[lbParamSymbols.itemIndex];
tempIndex := fmCalculate.getArrayIndex(vtParameter,tempString);

// Check if the selected parameter is already displayed.
if (FmDisplayOutput.LblPar1.caption = tempString) or
   (FmDisplayOutput.LblPar2.caption = tempString) or
   (FmDisplayOutput.LblPar3.caption = tempString) or
   (FmDisplayOutput.LblPar4.caption = tempString) or
   (FmDisplayOutput.LblPar5.caption = tempString) or
   (FmDisplayOutput.LblPar6.caption = tempString) then
 begin
  messageDlg('That parameter is already displayed', mtWarning, [mbOK], 0);
  ParAlreadySelected:=True;
 end
else
 begin
  ParSelected:=tempString;
  ParSelectSuccess:=True;
{ // which of the labels in the display form was selected
  case whichEdparselected of
   1: begin
       FmDisplayOutput.LblPar1.caption := tempString;
       FmDisplayOutput.EdPar1.text := floatToStr(par[tempIndex].value);
       FmDisplayOutput.EdPar1.Enabled := true;
      end;
   2: begin
       FmDisplayOutput.LblPar2.caption := tempString;
       FmDisplayOutput.EdPar2.text := floatToStr(par[tempIndex].value);
       FmDisplayOutput.EdPar2.Enabled := true;   // fix necessary?
      end;
   3: begin
       FmDisplayOutput.LblPar3.caption := tempString;
       FmDisplayOutput.EdPar3.text := floatToStr(par[tempIndex].value);
       FmDisplayOutput.EdPar3.Enabled := true;
      end;
   4: begin
       FmDisplayOutput.LblPar4.caption := tempString;
       FmDisplayOutput.EdPar4.text := floatToStr(par[tempIndex].value);
       FmDisplayOutput.EdPar4.Enabled := true;
      end;
   5: begin
       FmDisplayOutput.LblPar5.caption := tempString;
       FmDisplayOutput.EdPar5.text := floatToStr(par[tempIndex].value);
       FmDisplayOutput.EdPar5.Enabled := true;
      end;
   6: begin
       FmDisplayOutput.LblPar6.caption := tempString;
       FmDisplayOutput.EdPar6.text := floatToStr(par[tempIndex].value);
       FmDisplayOutput.EdPar6.Enabled := true;
      end;
   else
    begin
     messageDlg('The value of whichEdparselected in FmParamList is invalid.',
      mtInformation, [mbOK], 0);
    end;
  end;    }
 end;
if not ParAlreadySelected then FmParamList.Close;
end;

procedure TFmParamList.btnCancelClick(Sender: TObject);
begin
  ParSelectSuccess:=False;
end;

procedure TFmParamList.rbParameterSymbolClick(Sender: TObject);
begin
 // make sure the symbols box is on top
 lbParamNames.Hide;
 lbParamSymbols.Show
end;

procedure TFmParamList.rbParameterNameClick(Sender: TObject);
begin
 // make sure the names box is on top
 lbParamSymbols.Hide;
 lbParamNames.Show;
end;

procedure TFmParamList.lbParamSymbolsClick(Sender: TObject);
begin
 // to always have the same name and symbol selected
 lbParamNames.itemIndex := lbParamSymbols.itemIndex;
end;

procedure TFmParamList.lbParamNamesClick(Sender: TObject);
begin
 // to always have the same name and symbol selected
 lbParamSymbols.itemIndex := lbParamNames.itemIndex;
end;

end.
