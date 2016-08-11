{*******************************************************}
{                                                       }
{           FastCube 2 QuickSort Templates              }
{                                                       }
{               Copyright (c) 2001-2014                 }
{           by Oleg Pryalkov, Paul Ishenin              }
{                  Fast Reports Inc.                    }
{*******************************************************}

unit fcQSortTemplate;
{$DEFINE COMPARE_LENGTH}

interface

implementation

type
  _fcxPointerArray = array[0..0] of Pointer;
  PfcxPointerArray = ^_fcxPointerArray;
  _fcxIntegerArray = array[0..0] of Integer;
  PfcxIntegerArray = ^_fcxIntegerArray;

  TfcxSortPointerCompare = function(AItem1, AItem2: Pointer): Integer of Object;

  function SampleCompare(AItem1, AItem2: Pointer): integer;
  begin
    if integer(AItem1) > integer(AItem2) then
      Result := 1
    else if integer(AItem1) < integer(AItem2) then
      Result := -1
    else
      Result := 0;
  end;

// ������� ���������� � �������������� ��������� ��������
  procedure SortRecurse(AList: PfcxPointerArray {��� ������}; AStart, AEnd: Integer; Compare: TfcxSortPointerCompare);
    procedure InternalSort(ALeft, ARight: Integer);
    var
      i, j, AMiddle: integer;
      AObject1, AObject2: Pointer; {��� ������}

      procedure Insert(const AILeft, AIRight: integer);
      var
        i1, j1: integer;
        AIObject: Pointer; {��� ������}
      begin
        for i1 := AILeft + 1 to AIRight do
        begin

          AIObject := AList[i1]; {��� ������}
          for j1 := i1 - 1 downto AILeft do
          begin
            if Compare(AList[j1], AIObject) <= 0 then {��� ������}
              break;
            AList[j1 + 1] := AList[j1]; {��� ������}
          end;
          AList[j1 + 1] := AIObject; {��� ������}
        end;
      end;

    begin
      while (ARight - ALeft) > 12 do
      begin
        AMiddle := (ALeft + ARight) shr 1;
        AObject1 := AList[AMiddle]; {��� ������}
        AList[AMiddle] := AList[ALeft]; {��� ������}
        i := succ(ALeft);
        j := ARight;
        while true do
        begin
          while (i < j) and (Compare(AObject1, AList[i]) > 0) do {��� ������}
            inc(i);
          while (j >= i) and (Compare(AList[j], AObject1) > 0) do {��� ������}
            dec(j);
          if (i >= j) then
            break;
          AObject2 := AList[i]; {��� ������}
          AList[i] := AList[j]; {��� ������}
          AList[j] := AObject2; {��� ������}
          dec(j);
          inc(i);
        end;
        AList[ALeft] := AList[j]; {��� ������}
        AList[j] := AObject1; {��� ������}
        if ((j - ALeft) <= (ARight - j)) then
        begin
          InternalSort(ALeft, j - 1);
          ALeft := succ(j);
        end
        else
        begin
          InternalSort(j + 1, ARight);
          ARight := pred(j);
        end;
      end;
      if ALeft < ARight then
        Insert(ALeft, ARight);
    end;
  begin
    InternalSort(AStart, AEnd);
  end;

// ������� ���������� ��� ������������� ��������
  procedure SortNoRecurse(AList: PfcxPointerArray {��� ������}; AStart, AEnd: Integer; Compare: TfcxSortPointerCompare);
    procedure Insert(const AILeft, AIRight: integer);
    var
      i1, j1: integer;
      AIObject: Pointer; {��� ������}
    begin
      for i1 := AILeft + 1 to AIRight do
      begin

        AIObject := AList[i1]; {��� ������}
        for j1 := i1 - 1 downto AILeft do
        begin
          if Compare(AList[j1], AIObject) <= 0 then {��� ������}
            break;
          AList[j1 + 1] := AList[j1]; {��� ������}
        end;
        AList[j1 + 1] := AIObject; {��� ������}
      end;
    end;

    procedure InternalSort(ASLeft, ASRight: Integer);
    var
      i, j, AMiddle: integer;
      AObject1, AObject2: pointer; {��� ������}
      ALeftStack, ARightStack: PfcxIntegerArray;
      AStackSize: integer;
      AStackPos: integer;
      ALeft, ARight: Integer;
    begin
      AStackSize := 2048;
      GetMem(ALeftStack, AStackSize * SizeOf(integer));
      GetMem(ARightStack, AStackSize * SizeOf(integer));
      AStackPos := 0;
      ALeftStack[0] := ASLeft;
      ARightStack[0] := ASRight;
      while AStackPos >= 0 do
      begin
        ALeft := ALeftStack[AStackPos];
        ARight := ARightStack[AStackPos];
        dec(AStackPos);
        while (ARight - ALeft) > 12 do
        begin
          AMiddle := (ALeft + ARight) shr 1;
          AObject1 := AList[AMiddle]; {��� ������}
          AList[AMiddle] := AList[ALeft]; {��� ������}
          i := succ(ALeft);
          j := ARight;
          while true do
          begin
            while (i < j) and (Compare(AObject1, AList[i]) > 0) do {��� ������}
              inc(i);
            while (j >= i) and (Compare(AList[j], AObject1) > 0) do {��� ������}
              dec(j);
            if (i >= j) then
              break;
            AObject2 := AList[i]; {��� ������}
            AList[i] := AList[j]; {��� ������}
            AList[j] := AObject2; {��� ������}
            dec(j);
            inc(i);
          end;
          AList[ALeft] := AList[j]; {��� ������}
          AList[j] := AObject1; {��� ������}
{$IFDEF COMPARE_LENGTH}
          if (j - ALeft) <= (ARight - j) then
          begin
{$ENDIF}
            if (j + 1) < ARight then
            begin
              inc(AStackPos);
              if AStackPos > (AStackSize - 1) then
              begin
                AStackSize := AStackSize + 2048;
                ReallocMem(ALeftStack, AStackSize * SizeOf(integer));
                ReallocMem(ARightStack, AStackSize * SizeOf(integer));
              end;
              ALeftStack[AStackPos] := j + 1;
              ARightStack[AStackPos] := ARight;
            end;
            ARight := j - 1;
{$IFDEF COMPARE_LENGTH}
          end
          else
          begin
            if (j - 1) > ALeft then
            begin
              inc(AStackPos);
              if AStackPos > (AStackSize - 1) then
              begin
                AStackSize := AStackSize + 2048;
                ReallocMem(ALeftStack, AStackSize * SizeOf(integer));
                ReallocMem(ARightStack, AStackSize * SizeOf(integer));
              end;
              ALeftStack[AStackPos] := ALeft;
              ARightStack[AStackPos] := j - 1;
            end;
            ALeft := j + 1;
          end;
{$ENDIF}
        end;
        if ALeft < ARight then
          Insert(ALeft, ARight);
      end;
      FreeMem(ALeftStack);
      FreeMem(ARightStack);
    end;
  begin
    if (AEnd - AStart) > 12 then
      InternalSort(AStart, AEnd)
    else
      Insert(AStart, AEnd);
  end;

// ������� ���������� ��� ������������� �������� � ������������:
// ���� ��� �������� ������ ����� ����������, �� ����� �� ������������.
// ���� ��������� ��� ������� ������������� ������.
  procedure SortNoRecurseNotSwapEqual(AList: PfcxPointerArray {��� ������}; AStart, AEnd: Integer; Compare: TfcxSortPointerCompare);
    procedure Insert(const AILeft, AIRight: integer);
    var
      i1, j1: integer;
      AIObject: Pointer; {��� ������}
    begin
      for i1 := AILeft + 1 to AIRight do
      begin

        AIObject := AList[i1]; {��� ������}
        for j1 := i1 - 1 downto AILeft do
        begin
          if Compare(AList[j1], AIObject) <= 0 then {��� ������}
            break;
          AList[j1 + 1] := AList[j1]; {��� ������}
        end;
        AList[j1 + 1] := AIObject; {��� ������}
      end;
    end;

    procedure InternalSort(ASLeft, ASRight: Integer);
    var
      i, j, AMiddle: integer;
      AObject1, AObject2: pointer; {��� ������}
      ALeftStack, ARightStack: PfcxIntegerArray;
      AStackSize: integer;
      AStackPos: integer;
      ALeft, ARight: Integer;
      ARes1, ARes2: Integer;
    begin
      AStackSize := 2048;
      GetMem(ALeftStack, AStackSize * SizeOf(integer));
      GetMem(ARightStack, AStackSize * SizeOf(integer));
      AStackPos := 0;
      ALeftStack[0] := ASLeft;
      ARightStack[0] := ASRight;
      ARes1 := 0;
      ARes2 := 0;
      while AStackPos >= 0 do
      begin
        ALeft := ALeftStack[AStackPos];
        ARight := ARightStack[AStackPos];
        dec(AStackPos);
        while (ARight - ALeft) > 12 do
        begin
          AMiddle := (ALeft + ARight) shr 1;
          AObject1 := AList[AMiddle]; {��� ������}
          AList[AMiddle] := AList[ALeft]; {��� ������}
          i := succ(ALeft);
          j := ARight;
          while true do
          begin
            while (i < j) do
            begin
              ARes1 := Compare(AObject1, AList[i]);  {��� ������}
              if ARes1 <= 0 then
                break;
              inc(i);
            end;
            while (j >= i) do
            begin
              ARes2 := Compare(AList[j], AObject1);  {��� ������}
              if ARes2 <= 0 then
                break;
              dec(j);
            end;
            if (i >= j) then
              break;
            if (ARes1 <> 0) or (ARes2 <> 0) then
            begin
              AObject2 := AList[i]; {��� ������}
              AList[i] := AList[j]; {��� ������}
              AList[j] := AObject2; {��� ������}
            end;
            dec(j);
            inc(i);
          end;
          AList[ALeft] := AList[j]; {��� ������}
          AList[j] := AObject1; {��� ������}
{$IFDEF COMPARE_LENGTH}
          if (j - ALeft) <= (ARight - j) then
          begin
{$ENDIF}
            if (j + 1) < ARight then
            begin
              inc(AStackPos);
              if AStackPos > (AStackSize - 1) then
              begin
                AStackSize := AStackSize + 2048;
                ReallocMem(ALeftStack, AStackSize * SizeOf(integer));
                ReallocMem(ARightStack, AStackSize * SizeOf(integer));
              end;
              ALeftStack[AStackPos] := j + 1;
              ARightStack[AStackPos] := ARight;
            end;
            ARight := j - 1;
{$IFDEF COMPARE_LENGTH}
          end
          else
          begin
            if (j - 1) > ALeft then
            begin
              inc(AStackPos);
              if AStackPos > (AStackSize - 1) then
              begin
                AStackSize := AStackSize + 2048;
                ReallocMem(ALeftStack, AStackSize * SizeOf(integer));
                ReallocMem(ARightStack, AStackSize * SizeOf(integer));
              end;
              ALeftStack[AStackPos] := ALeft;
              ARightStack[AStackPos] := j - 1;
            end;
            ALeft := j + 1;
          end;
{$ENDIF}
        end;
        if ALeft < ARight then
          Insert(ALeft, ARight);
      end;
      FreeMem(ALeftStack);
      FreeMem(ARightStack);
    end;
  begin
    if (AEnd - AStart) > 12 then
      InternalSort(AStart, AEnd)
    else
      Insert(AStart, AEnd);
  end;

  procedure SortRecurseComments(AList: PfcxPointerArray {��� ������}; AStart, AEnd: Integer; Compare: TfcxSortPointerCompare);
    procedure InternalSort(ALeft, ARight: Integer);
    var
      i, j, AMiddle: integer;
      AObject1, AObject2: Pointer; {��� ������}

      procedure Insert(const AILeft, AIRight: integer);
      var
        i1, j1: integer;
        AIObject: Pointer; {��� ������}
      begin
        for i1 := AILeft + 1 to AIRight do
        begin

          AIObject := AList[i1]; {��� ������}
          for j1 := i1 - 1 downto AILeft do
          begin
            if Compare(AList[j1], AIObject) <= 0 then {��� ������}
              break;
            AList[j1 + 1] := AList[j1]; {��� ������}
          end;
          AList[j1 + 1] := AIObject; {��� ������}
        end;
      end;

    begin
// ����, ���� ����� ��������� ������ 12. ���� 12 � ������, �� ���������� ��������
      while (ARight - ALeft) > 12 do
      begin
// ��������
        AMiddle := (ALeft + ARight) shr 1;
// ��������� ����������� �������
        AObject1 := AList[AMiddle]; {��� ������}
// �� ����� ������������ �������� �����-�� ����� ����� ������� ������� ??
        AList[AMiddle] := AList[ALeft]; {��� ������}
// ����������� �������� [ALeft+1..ARight] ������������ ������������
        i := succ(ALeft);
        j := ARight;
        while true do
        begin
// ���� ����� �������, ������� ��� ������ ������������. ��� ���� �������, ���-�� �� ��������� �� ��������� ������� [j]
          while (i < j) and (Compare(AObject1, AList[i]) > 0) do {��� ������}
            inc(i);
// ���� ������ �������, ������� ��� ������ ������������. ��� ���� �������, ���-�� �� ��������� �� ��������� ������� [i]
          while (j >= i) and (Compare(AList[j], AObject1) > 0) do {��� ������}
            dec(j);
// ������ ���� � ���-�� ������� ��� ��������� �� ��������� �������. ������ ������ �����������.
          if (i >= j) then
            break;
// ������� ��� �������. ������ �� �������. SWAP
          AObject2 := AList[i]; {��� ������}
          AList[i] := AList[j]; {��� ������}
          AList[j] := AObject2; {��� ������}
// ��������� � ��������� ���������. (�������� ��������� � ������).
          dec(j);
          inc(i);
        end;
// ����� �� �����, ������ ����������� �������.
// ������� [j+1] - ������, ��� ��������� �������, � [j-1] - ������
// � ������� [j] - ���� ������, ��� ��������� �������. �������:
// ��������� ������� [j] �� ������� ������ �������� [ALeft].
        AList[ALeft] := AList[j]; {��� ������}
// � �� ��� ����� ���������� ��� ����������� ���������
        AList[j] := AObject1; {��� ������}
// � ���������� �� ���������� [ALeft..ARight] � ��� ��������� �������� ������������ ������� j:
// ����� ������ ��� ������, � ������ ������ ��� ������ �������� [j]
// ������ ���� ��������� �������������� ����� � ������ ��������
// ��� ���������� �������� �������� InternalSort ��� ������� ��������. � ������� ���������� ������ � �����.
        if ((j - ALeft) <= (ARight - j)) then
        begin
// ������� �������� �����. �������� InternalSort ��� ��: [ALeft, j - 1]
          InternalSort(ALeft, j - 1);
// ������� �������� ������. ������������� ��� �������� ������� ����� ����� �������
          ALeft := succ(j);
        end
        else
        begin
// ������� �������� ������. �������� InternalSort ��� ��: [j + 1, ARight]
          InternalSort(j + 1, ARight);
// ������� �������� �����. ������������� ��� �������� ������� ����� ������ �������
          ARight := pred(j);
        end;
      end;
// ���������� �������� �������. ����� ������� �������� �� ALeft < ARight, ����� �������� ������ ��� ������ ��������
      if ALeft < ARight then
        Insert(ALeft, ARight);
    end;
  begin
    InternalSort(AStart, AEnd);
  end;

  procedure SortNoRecurseComments(AList: PfcxPointerArray {��� ������}; AStart, AEnd: Integer; Compare: TfcxSortPointerCompare);
    procedure Insert(const AILeft, AIRight: integer);
    var
      i1, j1: integer;
      AIObject: Pointer; {��� ������}
    begin
      for i1 := AILeft + 1 to AIRight do
      begin

        AIObject := AList[i1]; {��� ������}
        for j1 := i1 - 1 downto AILeft do
        begin
          if Compare(AList[j1], AIObject) <= 0 then {��� ������}
            break;
          AList[j1 + 1] := AList[j1]; {��� ������}
        end;
        AList[j1 + 1] := AIObject; {��� ������}
      end;
    end;

    procedure InternalSort(ASLeft, ASRight: Integer);
    var
      i, j, AMiddle: integer;
      AObject1, AObject2: pointer; {��� ������}
      ALeftStack, ARightStack: PfcxIntegerArray;
      AStackSize: integer;
      AStackPos: integer;
      ALeft, ARight: Integer;
    begin
// ������� ������ ��� ����
      AStackSize := 2048;
      GetMem(ALeftStack, AStackSize * SizeOf(integer));
      GetMem(ARightStack, AStackSize * SizeOf(integer));

// ������� � ���� �������� ����������
      AStackPos := 0;
      ALeftStack[0] := ASLeft;
      ARightStack[0] := ASRight;
// ����, ���� ���� ���������� �� ������
      while AStackPos >= 0 do
      begin
// ������� ����������
        ALeft := ALeftStack[AStackPos];
        ARight := ARightStack[AStackPos];
// �������� ��������� ����� �����
        dec(AStackPos);
// ����, ���� ����� ��������� ������ 12. ���� 12 � ������, �� ���������� ��������
        while (ARight - ALeft) > 12 do
        begin
// ��������
          AMiddle := (ALeft + ARight) shr 1;
// ��������� ����������� �������
          AObject1 := AList[AMiddle]; {��� ������}
// �� ����� ������������ �������� �����-�� ����� ����� ������� ������� ??
          AList[AMiddle] := AList[ALeft]; {��� ������}
// ����������� �������� [ALeft+1..ARight] ������������ ������������
          i := succ(ALeft);
          j := ARight;
          while true do
          begin
// ���� ����� �������, ������� ��� ������ ������������. ��� ���� �������, ���-�� �� ��������� �� ��������� ������� [j]
            while (i < j) and (Compare(AObject1, AList[i]) > 0) do {��� ������}
              inc(i);
// ���� ������ �������, ������� ��� ������ ������������. ��� ���� �������, ���-�� �� ��������� �� ��������� ������� [i]
            while (j >= i) and (Compare(AList[j], AObject1) > 0) do {��� ������}
              dec(j);
// ������ ���� � ���-�� ������� ��� ��������� �� ��������� �������. ������ ������ �����������. ������� �� �����.
            if (i >= j) then
              break;
// ������� ��� �������. ������ �� �������. SWAP
            AObject2 := AList[i]; {��� ������}
            AList[i] := AList[j]; {��� ������}
            AList[j] := AObject2; {��� ������}
// ��������� � ��������� ���������. (�������� ��������� � ������).
            dec(j);
            inc(i);
          end;
// ����� �� �����, ������ ����������� �������.
// ������� [j+1] - ������ ��� ����� ���������� ��������, � [j-1] - ������ ��� �����
// � ������� [j] - ���� ������ ��� ����� ���������� ��������, � ��� ����, ���-�� ��� �����. �������:
// ��������� ������� [j] �� ������� ������ �������� [ALeft].
          AList[ALeft] := AList[j]; {��� ������}
// � �� ��� ����� ���������� ��� ����������� ���������
          AList[j] := AObject1; {��� ������}
// ������ j ��������� �� ����������� ������ � ������� �����������,
// � ���������� �� ���������� [ALeft..ARight] � ��� ��������� �������� ������������ ������� j:
// ����� ������ ��� ������, � ������ ������ ��� ������ �������� [j]
// ������ ���� ��������� �������������� ����� � ������ ��������
// ������ �������� ������� � ���� (�� ��� ���� ������ � ���� ������� ��������, � ������� ����� ���������, �� ��������� ����������� �� ����������)
          if (j + 1) < ARight then
          begin
// ���� ������ ��� 1 ������� � ������ �������� ����������
// �� ���������� ������ ���������� � ���� ��� ����������� �������
            inc(AStackPos);
            if AStackPos > (AStackSize - 1) then
            begin
// ����������� ������ �����, ���� ����
              AStackSize := AStackSize + 2048;
              ReallocMem(ALeftStack, AStackSize * SizeOf(integer));
              ReallocMem(ARightStack, AStackSize * SizeOf(integer));
            end;
            ALeftStack[AStackPos] := j + 1;
            ARightStack[AStackPos] := ARight;
          end;
// � ����� ��������� ���������
// ������������� ������ ������� ��� ������� ����� �������� ����������
          ARight := j - 1;
        end;
// ���������� �������� ������� ��� ���������. ����� ������� �������� �� ALeft < ARight, ����� �������� ������ ��� ������ ��������
        if ALeft < ARight then
          Insert(ALeft, ARight);
      end;
// ������������ �����
      FreeMem(ALeftStack);
      FreeMem(ARightStack);
    end;
  begin
    if (AEnd - AStart) > 12 then
      InternalSort(AStart, AEnd)
    else
      Insert(AStart, AEnd);
  end;

  procedure SortNoRecurseNotSwapEqualComments(AList: PfcxPointerArray {��� ������}; AStart, AEnd: Integer; Compare: TfcxSortPointerCompare);
    procedure Insert(const AILeft, AIRight: integer);
    var
      i1, j1: integer;
      AIObject: Pointer; {��� ������}
    begin
      for i1 := AILeft + 1 to AIRight do
      begin

        AIObject := AList[i1]; {��� ������}
        for j1 := i1 - 1 downto AILeft do
        begin
          if Compare(AList[j1], AIObject) <= 0 then {��� ������}
            break;
          AList[j1 + 1] := AList[j1]; {��� ������}
        end;
        AList[j1 + 1] := AIObject; {��� ������}
      end;
    end;

    procedure InternalSort(ASLeft, ASRight: Integer);
    var
      i, j, AMiddle: integer;
      AObject1, AObject2: pointer; {��� ������}
      ALeftStack, ARightStack: PfcxIntegerArray;
      AStackSize: integer;
      AStackPos: integer;
      ALeft, ARight: Integer;
      ARes1, ARes2: Integer;
    begin
// ������� ������ ��� ����
      AStackSize := 2048;
      GetMem(ALeftStack, AStackSize * SizeOf(integer));
      GetMem(ARightStack, AStackSize * SizeOf(integer));

// ������� � ���� �������� ����������
      AStackPos := 0;
      ALeftStack[0] := ASLeft;
      ARightStack[0] := ASRight;
      ARes1 := 0;
      ARes2 := 0;
// ����, ���� ���� ���������� �� ������
      while AStackPos >= 0 do
      begin
// ������� ����������
        ALeft := ALeftStack[AStackPos];
        ARight := ARightStack[AStackPos];
// �������� ��������� ����� �����
        dec(AStackPos);
// ����, ���� ����� ��������� ������ 12. ���� 12 � ������, �� ���������� ��������
        while (ARight - ALeft) > 12 do
        begin
// ��������
          AMiddle := (ALeft + ARight) shr 1;
// ��������� ����������� �������
          AObject1 := AList[AMiddle]; {��� ������}
// �� ����� ������������ �������� �����-�� ����� ����� ������� ������� ??
          AList[AMiddle] := AList[ALeft]; {��� ������}
// ����������� �������� [ALeft+1..ARight] ������������ ������������
          i := succ(ALeft);
          j := ARight;
          while true do
          begin
// ���� ����� �������, ������� ��� ������ ������������. ��� ���� �������, ���-�� �� ��������� �� ��������� ������� [j]
            while (i < j) do {��� ������}
            begin
              ARes1 := Compare(AObject1, AList[i]);
              if ARes1 <= 0 then
                break;
              inc(i);
            end;
// ���� ������ �������, ������� ��� ������ ������������. ��� ���� �������, ���-�� �� ��������� �� ��������� ������� [i]
            while (j >= i) do {��� ������}
            begin
              ARes2 := Compare(AList[j], AObject1);
              if ARes2 <= 0 then
                break;
              dec(j);
            end;
// ������ ���� � ���-�� ������� ��� ��������� �� ��������� �������. ������ ������ �����������. ������� �� �����.
            if (i >= j) then
              break;
// ������� ��� �������. ������ �� �������. SWAP
            if (ARes1 <> 0) or (ARes2 <> 0) then
            begin
// �� ������, ���� ��� �� �����
              AObject2 := AList[i]; {��� ������}
              AList[i] := AList[j]; {��� ������}
              AList[j] := AObject2; {��� ������}
            end;
// ��������� � ��������� ���������. (�������� ��������� � ������).
            dec(j);
            inc(i);
          end;
// ����� �� �����, ������ ����������� �������.
// ������� [j+1] - ������ ��� ����� ���������� ��������, � [j-1] - ������ ��� �����
// � ������� [j] - ���� ������ ��� ����� ���������� ��������, � ��� ����, ���-�� ��� �����. �������:
// ��������� ������� [j] �� ������� ������ �������� [ALeft].
          AList[ALeft] := AList[j]; {��� ������}
// � �� ��� ����� ���������� ��� ����������� ���������
          AList[j] := AObject1; {��� ������}
// ������ j ��������� �� ����������� ������ � ������� �����������,
// � ���������� �� ���������� [ALeft..ARight] � ��� ��������� �������� ������������ ������� j:
// ����� ������ ��� ������, � ������ ������ ��� ������ �������� [j]
// ������ ���� ��������� �������������� ����� � ������ ��������
// ������ �������� ������� � ���� (�� ��� ���� ������ � ���� ������� ��������, � ������� ����� ���������, �� ��������� ����������� �� ����������)
          if (j + 1) < ARight then
          begin
// ���� ������ ��� 1 ������� � ������ �������� ����������
// �� ���������� ������ ���������� � ���� ��� ����������� �������
            inc(AStackPos);
            if AStackPos > (AStackSize - 1) then
            begin
// ����������� ������ �����, ���� ����
              AStackSize := AStackSize + 2048;
              ReallocMem(ALeftStack, AStackSize * SizeOf(integer));
              ReallocMem(ARightStack, AStackSize * SizeOf(integer));
            end;
            ALeftStack[AStackPos] := j + 1;
            ARightStack[AStackPos] := ARight;
          end;
// � ����� ��������� ���������
// ������������� ������ ������� ��� ������� ����� �������� ����������
          ARight := j - 1;
        end;
// ���������� �������� ������� ��� ���������. ����� ������� �������� �� ALeft < ARight, ����� �������� ������ ��� ������ ��������
        if ALeft < ARight then
          Insert(ALeft, ARight);
      end;
// ������������ �����
      FreeMem(ALeftStack);
      FreeMem(ARightStack);
    end;
  begin
    if (AEnd - AStart) > 12 then
      InternalSort(AStart, AEnd)
    else
      Insert(AStart, AEnd);
  end;

end.
