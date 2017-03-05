{**********************************************************
Copyright (C) 2012-2016
Zeljko Cvijanovic www.zeljus.com (cvzeljko@gmail.com) &
Miran Horjak usbdoo@gmail.com
***********************************************************}

unit DB;

{$mode objfpc}{$H+}
{$modeswitch unicodestrings}
{$namespace zeljus.com.units}

interface

uses
  androidr15, DataBase, StdCtrls, Dialogs;

type
  TFieldDef = class;

  TCreateViewMethod = function (aContext: ACContext; aField: TFieldDef): AVView ;

  TDataType = (ftNull, ftInteger, ftFloat, ftString, ftBlob, ftDateTime);
  TEditCharCase = (eccNormal, eccLowerCase, eccUpperCase);
  TFieldView = (fvTextView, fvEditText);

  { TValue }

  TValue = class
    FValue: JLString;
  private
    function GetAsString: JLString;
    function GetFloat: jfloat;
    function GetHex: JLString;
    function GetInt: jint;
    procedure SetAsString(Value: JLString);
    procedure SetFloat(Value: jfloat);
    procedure SetHex(Value: JLString);
    procedure SetInt(Value: jint);
  public
   constructor Create; overload; virtual;
  public
   property AsString: JLString read GetAsString write SetAsString;
   property AsFloat: jfloat read GetFloat write SetFloat;
   property AsHex: JLString read GetHex write SetHex;
   property AsInteger: jint read GetInt write SetInt;
  end;

  { TField }

   TField = class
   private
    FFieldNo: jint;
    FDataType: TDataType;
    FReadOnly: jboolean;
    FVisible: jboolean;
    FOldValue: TValue;
    FName: JLString;
    FDisplayName: JLString;
    FValue: TValue;
    FChange: jboolean;
    FCharCase: TEditCharCase;
    FPrimaryKey: jboolean;
   public
    constructor create; overload; virtual;
   public
    property FieldNo: jint read FFieldNo write FFieldNo;
    property DataType: TDataType read FDataType write FDataType;
    property ReadOnly: jboolean read FReadOnly write FReadOnly;
    property Visible: jboolean read FVisible write FVisible;
    property Value: TValue read FValue write FValue;
    property OldValue: TValue read FOldValue write FOldValue;
    property Name: JLString read FName write FName;
    property DisplayName: JLString read FDisplayName write FDisplayName;
    property Change: jboolean read FChange write FChange;
    property CharCase: TEditCharCase read FCharCase write FCharCase;
    property PrimaryKey: jboolean read FPrimaryKey write FPrimaryKey;
  end;

  { TFieldDef }

  TFieldDef = class(JUArrayList)
  private
   function GetChange(Index: jint): jboolean;
   function GetCharCase(Index: jint): TEditCharCase;
   function GetDataType(Index: jint): TDataType;
   function GetDisplayName(Index: jint): JLString;
   function GetFieldNo(Index: jint): jint;
   function GetName(Index: jint): JLString;
   function GetOldValue(Index: jint): TValue;
   function GetReadOnly(Index: jint): jboolean;
   function GetValue(Index: jint): TValue;
   function GetVisible(Index: jint): jboolean;
   procedure SetChange(Index: jint; Value: jboolean);
   procedure SetCharCase(Index: jint; Value: TEditCharCase);
   procedure SetDataType(Index: jint; Value: TDataType);
   procedure SetDisplayName(Index: jint; Value: JLString);
   procedure SetName(Index: jint; Value: JLString);
   procedure SetOldValue(Index: jint; Value: TValue);
   procedure SetReadOnly(Index: jint; Value: jboolean);
   procedure SetValue(Index: jint; Value: TValue);
   procedure SetVisible(Index: jint; Value: jboolean);
  public
   constructor create; overload; virtual;
   procedure AddField(aName: JLString; aDataType: TDataType);
  public
   property FieldCount: jint read size;
   property FieldNo[Index: jint]: jint read GetFieldNo;
   property Change[Index: jint]: jboolean read GetChange write SetChange;
   property CharCase[Index: jint]: TEditCharCase read GetCharCase write SetCharCase;
   property DataType[Index: jint]: TDataType read GetDataType write SetDataType;
   property DisplayName[Index: jint]: JLString read GetDisplayName write SetDisplayName;
   property Name[Index: jint]: JLString read GetName write SetName;
   property OldValue[Index: jint]: TValue read GetOldValue write SetOldValue;
   property ReadOnly[Index: jint]: jboolean read GetReadOnly write SetReadOnly;
   property Value[Index: jint]: TValue read GetValue write SetValue;
   property Visible[Index: jint]: jboolean read GetVisible write SetVisible;
  end;

  { TCursorDataSet }

  TCursorDataSet = class
     FIndex: jint;
     FCount: jint;
     FDatabase: TDataBase;
     FSQLSelect: JLString;
     FSQLInsert: JLString;
     FSQLUpdate: JLString;
     FSQLDelete: JLString;
     FFields: JUArrayList;
     FFieldAll: TFieldDef;
     FTableName: JLString;
     function ReadFieldDef(aCursor: ADCursor): TFieldDef;
     procedure ReadFieldDefType;
     procedure DefineCursor(Value: ADCursor);
  protected
     procedure ExecuteSQLDataBase(SQLNew: JLString; aFieldDef: TFieldDef);
  private
    function GetFieldDef: TFieldDef;
    procedure SetIndex(Value: jint);
    procedure SetSelect(Value: JLString);
    procedure SetTableName(Value: JLString);
   public
    constructor create;  overload; virtual;
    procedure Next;
    procedure Prev;
    procedure Last;
    procedure First;
    procedure Refresh;

    procedure Insert(aFieldDef: TFieldDef);
    procedure Delete;
    procedure Update;
   public
    property DataBase: TDataBase read FDataBase write FDataBase;
    property SQLSelect: JLString write SetSelect;
    property SQLInsert: JLString write FSQLInsert;
    property SQLDelete: JLString write FSQLDelete;
    property SQLUpdate: JLString write FSQLUpdate;
    property Field: TFieldDef read GetFieldDef;
    property Fields: JUArrayList read FFields;
    property Count: jint read FCount;
    property Index: jint read FIndex write SetIndex;

    property TableName: JLString write SetTableName;
    property FieldAll: TFieldDef read FFieldAll;
  end;

  { TDataSetAddapter }

  TDataSetAddapter = class(AWArrayAdapter)
    FCursorDataSet: TCursorDataSet;
    FObjctView: AVView;
    FCreateView: TCreateViewMethod;
    function CreateViewMethod(aContext: ACContext; aField: TFieldDef): AVView; //overload;
  public
    constructor create(aContext: ACContext; para2: jint; aCursorDataSet: TCursorDataSet); overload;
    function getView(para1: jint; aView: AVView; aViewGroup: AVViewGroup): AVView;  override;
    property CreateView: TCreateViewMethod read FCreateView write FCreateView;
    property CursorDataSet: TCursorDataSet read FCursorDataSet;
  end;

  { TDBEditText }

  TDBEditText = class(TEditText)
    FField: TField;
  protected
    function TestInputType(aValue: JLString; aDataType: TDataType): jboolean;
    function InputKeyboard(aDataType: TDataType; aEditCharCase: TEditCharCase): jint;
  private
    FonChangeTextE: TOnChangeTextEvent;
    procedure GetChangeText(para1: JLObject); overload;
  public
    constructor create(para1: ACContext; aFieldDef: TFieldDef; aIndexField: jint); overload;
  public
    property onChangeText: TOnChangeTextEvent read FOnChangeTextE write FOnChangeTextE;
    property Field: TField read FField;
  end;

  { TDBTextView }

  TDBTextView = class(TTextView)
    FField: TFieldDef;
    FIndexField: jint;
  public
    constructor create(para1: ACContext;  aField: TFieldDef; aIndexField: jint); overload;
    procedure Refresh;
  end;

  { TDBDialog }

  TDBDialog = class(TDialog)
    FField: TFieldDef;
    FEditForms: AWScrollView;
  protected
    procedure InsertEditForms;
  private
    procedure SetField(Value: TFieldDef);
  public
    constructor create(para1: ACContext); overload; override;
  public
    property Field: TFieldDef read FField write SetField;
  end;

  { TDBGridViewLayout }

  TDBGridViewLayout = class(TGridViewLayout)
  private
    FAdapter: TDataSetAddapter;
    FCursorDataSet: TCursorDataSet;

    FEditDialog: TDBDialog;
    FDeleteDialog: TDialog;

    FIDRecord: jint;
    FDeletedFieldMessage: JLString;
  protected
    function LongItemClick(para1: AWAdapterView; para2: AVView; para3: jint; para4: jlong): jboolean;
    procedure ItemClickListener (para1: AWAdapterView; para2: AVView; para3: jint; para4: jlong);
    procedure onClickDialog (para1: ACDialogInterface; para2: jint);
  private
    const
       id_delete = 1;
       id_edit = 2;
  public
    constructor create(para1: ACContext; aDataBase: TDataBase); overload;
  public
    property Adapter: TDataSetAddapter read FAdapter;
  end;

  { TDBFindDialog }

  TDBFindDialog = class(TDialog)
    FEditText: TEditText;
    FSQLSelect: JLString;
    FGridViewLayout: TGridViewLayout;
    FAdapter: TDataSetAddapter;
    FLookupResultField: JLString;
    FWhere: JLString;
  protected
    procedure ItemClickListener (para1: AWAdapterView; para2: AVView; para3: jint; para4: jlong);
    procedure onClickDialog (para1: ACDialogInterface; para2: jint);
    procedure ChangeText(para1: JLObject);
  public
    constructor create(para1: ACContext; aDataBase: TDataBase; aSQL: JLString; aLookupResultField: JLString; aTable: JLString; aWhere : JLstring = string('')); overload;
    procedure show; overload; override;
  public
    property Adapter: TDataSetAddapter read FAdapter;
  end;

implementation

{ TDBFindDialog }

procedure TDBFindDialog.ItemClickListener(para1: AWAdapterView; para2: AVView; para3: jint; para4: jlong);
begin
  FAdapter.CursorDataSet.Index := para3;
  onClickDialog(self, para3);
end;

procedure TDBFindDialog.onClickDialog(para1: ACDialogInterface; para2: jint);
begin
    onClick(para1, para2);
end;

procedure TDBFindDialog.ChangeText(para1: JLObject);
begin
   FAdapter.CursorDataSet.SQLSelect :=  JLString(FSQLSelect).concat(JLString(' where ').concat(FWhere).concat(' ( UPPER(').concat(FLookupResultField).concat(') like ''')).concat(FEditText.Text.toString.toUpperCase).concat(JLString('%'' ) ')).
                                          concat(' order by ').concat(FLookupResultField).concat(' ASC LIMIT 50');

  FAdapter.CursorDataSet.Refresh;
  FGridViewLayout.GridView.setAdapter(FAdapter);
end;


constructor TDBFindDialog.create(para1: ACContext; aDataBase: TDataBase; aSQL: JLString; aLookupResultField: JLString; aTable: JLString; aWhere: JLstring);
var
  layout: AWLinearLayout;
  cds: TCursorDataSet;
begin
  inherited create(para1);
  FSQLSelect := aSQL;
  FLookupResultField := aLookupResultField;
  FWhere := aWhere;

  layout:= AWLinearLayout.Create(getContext);
  layout.setOrientation(AWLinearLayout.VERTICAL);

     FEditText:= TEditText.create(getContext);
     FEditText.setInputType(ATInputType.TYPE_TEXT_FLAG_CAP_CHARACTERS);
     FEditText.setFocusableInTouchMode(true);
     FEditText.onChangeText := @ChangeText;
    layout.addView(FEditText);

     cds:= TCursorDataSet.create;
     cds.DataBase := aDataBase;
     cds.SQLSelect := FSQLSelect.concat(' LIMIT 50 ');
     cds.TableName := aTable;

    FAdapter:= TDataSetAddapter.create(getContext, AR.innerLayout.simple_list_item_1, cds);

     FGridViewLayout:= TGridViewLayout.create(getContext);
     FGridViewLayout.GridView.setAdapter(FAdapter);
     FGridViewLayout.onItemClickListener := @ItemClickListener;
    layout.addView(FGridViewLayout);

   setView(layout);
   AddButton(btPositive, JLString('<<'));
end;

procedure TDBFindDialog.show;
begin
  FEditText.Text := JLString('');

  FAdapter.CursorDataSet.Refresh;
  inherited show;
  getWindow.setSoftInputMode(AVWindowManager.InnerLayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
end;

{ TDBDialog }

procedure TDBDialog.InsertEditForms;
var
  i: integer;
  Flayout: AWLinearLayout;
begin
  FEditForms.removeAllViews;

  Flayout := AWLinearLayout.create(getContext);
  Flayout.setOrientation(AWLinearLayout.VERTICAL);

  for i:=0 to FField.FieldCount -1 do begin
    if FField.Visible[i] then begin

         Flayout.addView(TTextView.create(getContext) );
         with TTextView(Flayout.getChildAt(Flayout.getChildCount - 1)) do begin
            Text := FField.DisplayName[i];
           // setTypeface(nil, AGTypeface.ITALIC);
            case FField.CharCase[i] of
              eccNormal : Text := FField.DisplayName[i];
              eccLowerCase: Text := FField.DisplayName[i].toLowerCase;
              eccUpperCase: Text := FField.DisplayName[i].toUpperCase;
            end;
            setGravity(AVGravity.LEFT);
         end;

        if FField.ReadOnly[i] then
           Flayout.addView(TDBTextView.create(getContext, FField, i) )
        else
           Flayout.addView(TDBEditText.create(getContext, FField, i) );
    end;
  end;

  FEditForms.addView(Flayout);

end;

procedure TDBDialog.SetField(Value: TFieldDef);
begin
  //if FField = Value then Exit;
  FField := Value;
  InsertEditForms;
  setView(FEditForms);
end;

constructor TDBDialog.create(para1: ACContext);
begin
  inherited create(para1);
  FEditForms:= AWScrollView.create(getContext);
end;

{ TDBGridViewLayout }

function TDBGridViewLayout.LongItemClick(para1: AWAdapterView; para2: AVView; para3: jint; para4: jlong): jboolean;
var
  i: integer;
begin
  FAdapter.CursorDataSet.Index := para3;

  FDeletedFieldMessage:=''; // #10#13;
  for i:= 0 to FAdapter.CursorDataSet.Field.FieldCount - 1 do
     FDeletedFieldMessage := FDeletedFieldMessage.concat(FAdapter.CursorDataSet.Field.Value[i].AsString).concat(#10#13);

  with FDeleteDialog do begin //DELETE
    setMessage(FDeletedFieldMessage.concat(#10#13).concat('Are you sure?') );
    show;
  end;
  Result := true;
end;

procedure TDBGridViewLayout.ItemClickListener(para1: AWAdapterView; para2: AVView; para3: jint; para4: jlong);
begin
  FIDRecord := para3;
  FAdapter.CursorDataSet.Index := FIDRecord;

  with FEditDialog do begin //EDIT
    ID := id_edit;
    Field := FAdapter.CursorDataSet.Field;
    show;
  end;
end;

procedure TDBGridViewLayout.onClickDialog(para1: ACDialogInterface; para2: jint);
var
  i: integer;
begin
  case TDialog(para1).ID of
    id_delete: if para2 = -1 then begin
                 FAdapter.CursorDataSet.Delete;
                 FAdapter.clear;
                 FAdapter.CursorDataSet.Refresh;
                 FIDRecord := FAdapter.CursorDataSet.Index;
                 AWToast.makeText(getContext,
                                  JLString('Deleted: ').concat(#10#13).concat(FDeletedFieldMessage.toString),
                                  AWToast.LENGTH_LONG).show;
    				   end;
    id_edit: if para2 = -1 then begin
               FAdapter.CursorDataSet.Index := FIDRecord;

               for i:=0 to FEditDialog.Field.FieldCount - 1 do
                 FAdapter.CursorDataSet.Field.Value[i].AsString :=
                      FEditDialog.Field.Value[i].AsString;

               FAdapter.CursorDataSet.Update;
               FAdapter.clear;
               FAdapter.CursorDataSet.Refresh;
               FIDRecord := FAdapter.CursorDataSet.Index;
               AWToast.makeText(getContext, JLString('Save: '), AWToast.LENGTH_SHORT).show;
    					end;
  end;
end;

constructor TDBGridViewLayout.create(para1: ACContext; aDataBase: TDataBase);
begin
  inherited create(para1);
  FCursorDataSet:= TCursorDataSet.create;
  FCursorDataSet.DataBase := aDataBase;

  FAdapter := TDataSetAddapter.create(getContext, AR.innerLayout.simple_list_item_1, FCursorDataSet);
  GridView.setAdapter(FAdapter);

  onItemLongClickListener := @LongItemClick;
  onItemClickListener := @ItemClickListener;

  FDeleteDialog:= TDialog.create(getContext);
  with FDeleteDialog do begin
     ID := id_delete;
     setTitle(JLString('Delete record!!!'));
     AddButton(btPositive, JLString('Yes'));
     AddButton(btNegative, JLString('No'));
     OnClickListener := @onClickDialog;
  end;

  FEditDialog:= TDBDialog.create(getContext);
  with FEditDialog do begin
    setTitle(JLString('Edit data!!!'));
    AddButton(btPositive, JLString('Save'));
    AddButton(btNegative, JLString('Cancel'));
    OnClickListener := @onClickDialog;
  end;

end;


{ TDBTextView }

constructor TDBTextView.create(para1: ACContext; aField: TFieldDef; aIndexField: jint);
begin
  FField := aField;
  FIndexField := aIndexField;
  inherited Create(para1);
  if FField.size > 0 Then
    Text := FField.Value[FIndexField].AsString
  else Text := JLstring('');
end;

procedure TDBTextView.Refresh;
begin
  if FField.size > 0 Then
    Text := FField.Value[FIndexField].AsString
  else Text := JLstring('');
end;

{ TDBEditText }

function TDBEditText.TestInputType(aValue: JLString; aDataType: TDataType): jboolean;
begin
  try  {ftNull, ftInteger, ftFloat, ftString, ftBlob}
    case aDataType of
      ftInteger: JLInteger.parseInt(aValue.toString);
      ftFloat:   JLFloat.parseFloat(aValue.toString);
    end;
      Result := true;
   except
      Result := false;
   end;
end;

function TDBEditText.InputKeyboard(aDataType: TDataType; aEditCharCase: TEditCharCase): jint;
begin
 Result := ATInputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS;
 case aDataType of
    ftInteger: Result := ATInputType.TYPE_CLASS_PHONE;
    ftFloat  : Result := ATInputType.TYPE_CLASS_PHONE;
    ftDateTime:  Result := ATInputType.TYPE_DATETIME_VARIATION_DATE;
    ftString: case aEditCharCase of
                 eccUpperCase: Result:= ATInputType.TYPE_TEXT_FLAG_CAP_CHARACTERS;
              end;
    else Result := ATInputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS;
  end;
end;

procedure TDBEditText.GetChangeText(para1: JLObject);
begin
  if not TestInputType(Text.toString, FField.DataType) then Text := FField.Value.AsString
  else if not FField.ReadOnly then  FField.Value.AsString := Text.toString;

  FField.Change := FField.Value.AsString <> FField.OldValue.AsString;
  if Assigned(FOnChangeTextE) then FOnChangeTextE(self);
end;

constructor TDBEditText.create(para1: ACContext; aFieldDef: TFieldDef; aIndexField: jint);
begin
  FField := TField.create;
  inherited Create(para1);

  if aFieldDef.size > 0 Then begin
     FField.FieldNo := aFieldDef.FieldNo[aIndexField];
     FField.DataType := aFieldDef.DataType[aIndexField];
     FField.ReadOnly := aFieldDef.ReadOnly[aIndexField];
     FField.Visible := aFieldDef.Visible[aIndexField];
     FField.Value := aFieldDef.Value[aIndexField];
     FField.OldValue := aFieldDef.OldValue[aIndexField];
     FField.Name := aFieldDef.Name[aIndexField];
     FField.DisplayName := aFieldDef.DisplayName[aIndexField];
     FField.Change := aFieldDef.Change[aIndexField];
     FField.CharCase := aFieldDef.CharCase[aIndexField];
     //  FField.PrimaryKey := aCursorDataSet.Field.PrimaryKey[aIndexField];

     Text := FField.Value.AsString ;
  end else Text := JLstring('');

  setInputType(InputKeyboard(FField.DataType, FField.CharCase));
  inherited onChangeText := @GetChangeText;
end;


{ TDataSetAddapter }

function TDataSetAddapter.CreateViewMethod(aContext: ACContext; aField: TFieldDef): AVView;
begin
  if Assigned(FCreateView) then Result := FCreateView(aContext, aField)
  else Result:= AVView.create(getContext);
end;

constructor TDataSetAddapter.create(aContext: ACContext; para2: jint; aCursorDataSet: TCursorDataSet);
begin
  FCursorDataSet := aCursorDataSet;
  inherited create(aContext,  para2, FCursorDataSet.Fields);
end;

function TDataSetAddapter.getView(para1: jint; aView: AVView; aViewGroup: AVViewGroup): AVView;
var layout: AWLinearLayout;
begin
  FCursorDataSet.Index := para1;
  Result:=  CreateViewMethod(getContext, FCursorDataSet.Field);
end;


{ TCursorDataSet }

function TCursorDataSet.ReadFieldDef(aCursor: ADCursor): TFieldDef;
var
  i: integer;
  isValue: boolean;
begin
    isValue := aCursor.getCount <> 0;

     Result := TFieldDef.create;
     if FFieldAll.FieldCount > 0 then begin
        for i:=0 to aCursor.getColumnCount - 1 do begin
           Result.AddField(aCursor.getColumnName(i), FFieldAll.DataType[i]);
           if isValue then Result.Value[i].AsString := aCursor.getString(i);
           if isValue then Result.OldValue[i].AsString := Result.Value[i].AsString;
           Result.DisplayName[i] := FFieldAll.DisplayName[i];
           Result.CharCase[i] := FFieldAll.CharCase[i];
           Result.ReadOnly[i] := FFieldAll.ReadOnly[i];
           Result.Visible[i] := FFieldAll.Visible[i];
         end;
     end else
     for i:=0 to aCursor.getColumnCount - 1 do begin
        if aCursor.getType(i) = ADCursor.FIELD_TYPE_NULL then begin
    		    Result.AddField(aCursor.getColumnName(i), ftNull);
         if isValue then Result.Value[i].AsString := aCursor.getString(i);
         if isValue then Result.OldValue[i].AsString := Result.Value[i].AsString;
        end else if aCursor.getType(i) = ADCursor.FIELD_TYPE_INTEGER then begin
    		    Result.AddField(aCursor.getColumnName(i), ftInteger);
         if isValue then Result.Value[i].AsInteger := aCursor.getInt(i);
         if isValue then Result.OldValue[i].AsInteger := Result.Value[i].AsInteger;
        end else if aCursor.getType(i) = ADCursor.FIELD_TYPE_FLOAT then begin
    		    Result.AddField(aCursor.getColumnName(i), ftFloat);
         if isValue then Result.Value[i].AsFloat := aCursor.getFloat(i);
         if isValue then Result.OldValue[i].AsFloat := Result.Value[i].AsFloat;
        end else if aCursor.getType(i) = ADCursor.FIELD_TYPE_STRING then begin
    		    Result.AddField(aCursor.getColumnName(i), ftString);
         if isValue then Result.Value[i].AsString := aCursor.getString(i);
         if isValue then Result.OldValue[i].AsString := Result.Value[i].AsString;
        end else if aCursor.getType(i) = ADCursor.FIELD_TYPE_BLOB then begin
    		    Result.AddField(aCursor.getColumnName(i), ftBlob);
         if isValue then Result.Value[i].AsString := aCursor.getString(i);    //blob ?
         if isValue then Result.OldValue[i].AsString := Result.Value[i].AsString;
        end;
      end;

end;

procedure TCursorDataSet.ReadFieldDefType;
var i: integer;
   TempCursor: ADCursor;
begin
 FFieldAll.clear;
 try
   TempCursor := FDatabase.rawQuery(JLString('PRAGMA table_info( ').concat(FTableName).concat(' ) '), nil);

   if TempCursor.getCount > 0 then begin
       for i:=0 to  TempCursor.getCount - 1 do begin
            TempCursor.moveToPosition(i);
            if TempCursor.getType(2) = ADCursor.FIELD_TYPE_NULL    then FFieldAll.AddField(TempCursor.getString(1), ftNull)    else
            if TempCursor.getType(2) = ADCursor.FIELD_TYPE_INTEGER then FFieldAll.AddField(TempCursor.getString(1), ftInteger) else
            if TempCursor.getType(2) = ADCursor.FIELD_TYPE_FLOAT   then FFieldAll.AddField(TempCursor.getString(1), ftFloat)   else
            if TempCursor.getType(2) = ADCursor.FIELD_TYPE_STRING  then FFieldAll.AddField(TempCursor.getString(1), ftString)  else
            if TempCursor.getType(2) = ADCursor.FIELD_TYPE_BLOB    then FFieldAll.AddField(TempCursor.getString(1), ftBlob);
       end;
   end;
 except
 end;
end;

function TCursorDataSet.GetFieldDef: TFieldDef;
begin
  Result := TFieldDef(FFields.get(FIndex));
end;

procedure TCursorDataSet.SetIndex(Value: jint);
begin
  if (FIndex = Value) or (Value < 0) or (Value > FCount - 1) then Exit;
  FIndex := Value;
end;

procedure TCursorDataSet.DefineCursor(Value: ADCursor);
var
  i: integer;
begin
  FFields.clear;

  if (Value.getCount = 0) then begin
     FIndex:= 0;
     FCount:= 0;
     Exit;
  end;

  for i:= 0 to Value.getCount - 1 do begin
    Value.moveToPosition(i);
    FFields.add(ReadFieldDef(Value));
  end;

  FIndex :=  0;
  FCount := FFields.size;
end;

procedure TCursorDataSet.ExecuteSQLDataBase(SQLNew: JLString; aFieldDef: TFieldDef);
var
  i: integer;
  TempSQL: JLString;
begin
  if ATTextUtils.isEmpty(SQLNew) or (aFieldDef.FieldCount < 1) then  Exit;
  TempSQL := SQLNew.toString;

  for i:=0 to  aFieldDef.FieldCount - 1 do
     TempSQL := TempSQL.replaceAll(JLString(string(':')).concat(aFieldDef.Name[i]).toString,
                JLString.format('''%s''' , [aFieldDef.Value[i].AsString ]).toString );

  FDatabase.execSQL(TempSQL);
  Refresh;
end;

procedure TCursorDataSet.SetSelect(Value: JLString);
begin
  if ATTextUtils.isEmpty(Value) then Exit;
  FSQLSelect := Value;
  DefineCursor(FDatabase.rawQuery(FSQLSelect, nil));
end;

procedure TCursorDataSet.SetTableName(Value: JLString);
begin
  FTableName := Value;
  ReadFieldDefType;
end;

constructor TCursorDataSet.create;
begin
  inherited Create;
  FFieldAll := TFieldDef.create;
  FFields:= JUArrayList.create;
  FIndex := 0;
  FCount := 0;
  FTableName := '"-"';
end;

procedure TCursorDataSet.Next;
begin
  if FIndex < FCount -1  then Inc(FIndex);
end;

procedure TCursorDataSet.Prev;
begin
  if FIndex < 0 then Dec(FIndex);
end;

procedure TCursorDataSet.Last;
begin
  if FCount > 0 then  FIndex := FCount -1;
end;

procedure TCursorDataSet.First;
begin
  FIndex := 0;
end;

procedure TCursorDataSet.Refresh;
var
  i: integer;
begin
  if ATTextUtils.isEmpty(FSQLSelect) then Exit;
  i:= FIndex;
  SetSelect(FSQLSelect);
  FIndex := i;
end;

procedure TCursorDataSet.Insert(aFieldDef: TFieldDef);
begin
   //Insert
  ExecuteSQLDataBase(FSQLInsert, aFieldDef);
end;

procedure TCursorDataSet.Delete;
begin
  //Delete
  ExecuteSQLDataBase(FSQLDelete, TFieldDef(FFields.get(FIndex)));
end;

procedure TCursorDataSet.Update;
begin
  //Update
  ExecuteSQLDataBase(FSQLUpdate, TFieldDef(FFields.get(FIndex)));
end;


{ TValue }

function TValue.GetAsString: JLString;
begin
  Result := FValue;
end;

function TValue.GetFloat: jfloat;
begin
  Result := JLFloat.parseFloat(FValue);
end;

function TValue.GetHex: JLString;
begin
  Result :=  upcase(JLInteger.toHexString(JLInteger.parseInt(FValue)));
end;

function TValue.GetInt: jint;
begin
  Result := JLInteger.parseInt(FValue);
end;

procedure TValue.SetAsString(Value: JLString);
begin
  FValue := Value;
end;

procedure TValue.SetFloat(Value: jfloat);
begin
  FValue := JLFloat.toString(Value);
end;

procedure TValue.SetHex(Value: JLString);
begin
  FValue :=  JLInteger.toString(JLInteger.parseInt(Value, 16));
end;

procedure TValue.SetInt(Value: jint);
begin
  FValue := JLInteger.toString(Value);
end;

constructor TValue.Create;
begin
  inherited Create;
end;

{ TField }

constructor TField.create;
begin
  inherited Create;
  FValue := TValue.Create;
  FOldValue := TValue.Create;
end;


{ TFieldDef }

function TFieldDef.GetChange(Index: jint): jboolean;
begin
  Result := TField(get(Index)).Change;
end;

function TFieldDef.GetDataType(Index: jint): TDataType;
begin
  Result := TField(get(Index)).DataType;
end;

function TFieldDef.GetDisplayName(Index: jint): JLString;
begin
  Result := TField(get(Index)).DisplayName;
end;

function TFieldDef.GetFieldNo(Index: jint): jint;
begin
  Result := TField(get(Index)).FieldNo;
end;

function TFieldDef.GetName(Index: jint): JLString;
begin
  Result := TField(get(Index)).Name;
end;

function TFieldDef.GetOldValue(Index: jint): TValue;
begin
  Result := TField(get(Index)).OldValue;
end;

function TFieldDef.GetReadOnly(Index: jint): jboolean;
begin
  Result := TField(get(Index)).ReadOnly;
end;

function TFieldDef.GetValue(Index: jint): TValue;
begin
   Result := TField(get(Index)).Value;
end;

function TFieldDef.GetVisible(Index: jint): jboolean;
begin
    Result := TField(get(Index)).Visible;
end;

procedure TFieldDef.SetChange(Index: jint; Value: jboolean);
begin
  TField(get(Index)).Change := Value;
end;

function TFieldDef.GetCharCase(Index: jint): TEditCharCase;
begin
   Result := TField(get(Index)).CharCase;
end;

procedure TFieldDef.SetCharCase(Index: jint; Value: TEditCharCase);
begin
  TField(get(Index)).CharCase := Value;
end;

procedure TFieldDef.SetDataType(Index: jint; Value: TDataType);
begin
   TField(get(Index)).DataType := Value;
end;

procedure TFieldDef.SetDisplayName(Index: jint; Value: JLString);
begin
  TField(get(Index)).DisplayName := Value;
end;

procedure TFieldDef.SetName(Index: jint; Value: JLString);
begin
   TField(get(Index)).Name := Value;
end;

procedure TFieldDef.SetOldValue(Index: jint; Value: TValue);
begin
  TField(get(Index)).OldValue := Value;
end;

procedure TFieldDef.SetReadOnly(Index: jint; Value: jboolean);
begin
   TField(get(Index)).ReadOnly := Value;
end;

procedure TFieldDef.SetValue(Index: jint; Value: TValue);
begin
  TField(get(Index)).Value := Value;
end;

procedure TFieldDef.SetVisible(Index: jint; Value: jboolean);
begin
   TField(get(Index)).Visible := Value;
end;

constructor TFieldDef.create;
begin
  inherited Create;
end;

procedure TFieldDef.AddField(aName: JLString; aDataType: TDataType);
begin
  add(TField.create);
  TField(get(size - 1)).Name := aName;
  TField(get(size - 1)).DisplayName := aName;
  TField(get(size - 1)).DataType := aDataType;
  TField(get(size - 1)).ReadOnly := False;
  TField(get(size - 1)).CharCase := eccNormal;
  TField(get(size - 1)).Visible := true;
  TField(get(size - 1)).FieldNo := size;
  TField(get(size - 1)).PrimaryKey := false;
end;


end.

