ChargeDataManager =
{
    m_ChargeReturnList = { }
}
--�ı�����
function ChargeDataManager.ChangeData(id, status)
    for _, v in pairs(ChargeDataManager.m_ChargeReturnList) do
        if v.id == id then
            v.status = status
        end
    end
end
--���º��״̬
function ChargeDataManager.GetRedPointStatus()
    local redPoint = false
    for _,v in pairs(ChargeDataManager.m_ChargeReturnList) do
     if v.status == 1 then
      redPoint = true
      break
     end
    end
    return redPoint
end

return ChargeDataManager
