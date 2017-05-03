<#--
This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<#-- See the mantle.ledger.LedgerReportServices.run#BalanceSheet service for data preparation -->

<#assign showDetail = (detail! == "true")>

<#macro showClass classInfo depth>
    <#-- skip classes with nothing posted -->
    <#if (classInfo.totalPostedByTimePeriod['ALL']!0) == 0><#return></#if>

    <tr>
        <td style="padding-left: ${(depth-1) * 2}.3em;">${ec.l10n.localize(classInfo.className)}</td>
        <#if (timePeriodIdList?size > 1)>
            <td class="text-right">${ec.l10n.formatCurrency(classInfo.postedByTimePeriod['ALL']!0, currencyUomId)}</td>
        </#if>
        <#list timePeriodIdList as timePeriodId>
            <td class="text-right">${ec.l10n.formatCurrency(classInfo.postedByTimePeriod[timePeriodId]!0, currencyUomId)}</td>
        </#list>
    </tr>
    <#list classInfo.glAccountInfoList! as glAccountInfo>
        <#if showDetail>
            <tr>
                <td style="padding-left: ${(depth-1) * 2 + 3}.3em;"><#if accountCodeFormatter??>${accountCodeFormatter.valueToString(glAccountInfo.accountCode)}<#else>${glAccountInfo.accountCode}</#if>: ${glAccountInfo.accountName}</td>
                <#if (timePeriodIdList?size > 1)>
                    <td class="text-right">${ec.l10n.formatCurrency(glAccountInfo.postedByTimePeriod['ALL']!0, currencyUomId)}</td>
                </#if>
                <#list timePeriodIdList as timePeriodId>
                    <td class="text-right">
                        <#if findEntryUrl??>
                            <#assign findEntryInstance = findEntryUrl.getInstance(sri, true).addParameter("glAccountId", glAccountInfo.glAccountId).addParameter("isPosted", "Y").addParameter("timePeriodId", timePeriodId)>
                            <a href="${findEntryInstance.getUrlWithParams()}">${ec.l10n.formatCurrency(glAccountInfo.postedByTimePeriod[timePeriodId]!0, currencyUomId)}</a>
                        <#else>
                            ${ec.l10n.formatCurrency(glAccountInfo.postedByTimePeriod[timePeriodId]!0, currencyUomId)}
                        </#if>
                    </td>
                </#list>
            </tr>
        <#else>
            <!-- ${glAccountInfo.accountCode}: ${glAccountInfo.accountName} ${glAccountInfo.postedByTimePeriod} -->
        </#if>
    </#list>
    <#list classInfo.childClassInfoList as childClassInfo>
        <@showClass childClassInfo depth + 1/>
    </#list>
    <#if classInfo.childClassInfoList?has_content>
        <tr<#if depth == 1> class="text-info"</#if>>
            <td style="padding-left: ${(depth-1) * 2}.3em;"><strong>${ec.l10n.localize("Total " + classInfo.className)}</strong></td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(classInfo.totalPostedByTimePeriod['ALL']!0, currencyUomId)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(classInfo.totalPostedByTimePeriod[timePeriodId]!0, currencyUomId)}</strong></td>
            </#list>
        </tr>
    </#if>
</#macro>

<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>${ec.l10n.localize("Income Statement")}</th>
            <#if (timePeriodIdList?size > 1)>
                <th class="text-right">All Periods</th>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <th class="text-right">${timePeriodIdMap[timePeriodId].periodName} (Closed: ${timePeriodIdMap[timePeriodId].isClosed})</th>
            </#list>
        </tr>
    </thead>
    <tbody>

        <@showClass classInfoById.REVENUE 1/>
        <@showClass classInfoById.CONTRA_REVENUE 1/>
        <tr class="text-info">
            <td><strong>${ec.l10n.localize("Net Revenue")}</strong> (${ec.l10n.localize("Revenue")} + ${ec.l10n.localize("Contra Revenue")})</td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right"><strong>${ec.l10n.formatCurrency((classInfoById.REVENUE.totalPostedByTimePeriod['ALL']!0) + (classInfoById.CONTRA_REVENUE.totalPostedByTimePeriod['ALL']!0), currencyUomId)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency((classInfoById.REVENUE.totalPostedByTimePeriod[timePeriodId]!0) + (classInfoById.CONTRA_REVENUE.totalPostedByTimePeriod[timePeriodId]!0), currencyUomId)}</strong></td>
            </#list>
        </tr>

        <@showClass classInfoById.COST_OF_SALES 1/>
        <tr class="text-success" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Gross Profit On Sales")}</strong> (${ec.l10n.localize("Net Revenue")} + ${ec.l10n.localize("Cost of Sales")})</td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(grossProfitOnSalesMap['ALL']!0, currencyUomId)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(grossProfitOnSalesMap[timePeriodId]!0, currencyUomId)}</strong></td>
            </#list>
        </tr>

        <@showClass classInfoById.INCOME 1/>
        <@showClass classInfoById.EXPENSE 1/>
        <tr class="text-success" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Net Operating Income")}</strong></td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(netOperatingIncomeMap['ALL']!0, currencyUomId)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(netOperatingIncomeMap[timePeriodId]!0, currencyUomId)}</strong></td>
            </#list>
        </tr>

        <@showClass classInfoById.NON_OP_EXPENSE 1/>
        <tr class="text-success" style="border-bottom: solid black;">
            <td><strong>${ec.l10n.localize("Net Income")}</strong></td>
            <#if (timePeriodIdList?size > 1)>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(netIncomeMap['ALL']!0, currencyUomId)}</strong></td>
            </#if>
            <#list timePeriodIdList as timePeriodId>
                <td class="text-right"><strong>${ec.l10n.formatCurrency(netIncomeMap[timePeriodId]!0, currencyUomId)}</strong></td>
            </#list>
        </tr>
    </tbody>
</table>
