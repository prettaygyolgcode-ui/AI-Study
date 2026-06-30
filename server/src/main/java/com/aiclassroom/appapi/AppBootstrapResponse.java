package com.aiclassroom.appapi;

import com.aiclassroom.aiasset.AiFriend;
import com.aiclassroom.aiasset.CreationCard;
import java.util.List;

public record AppBootstrapResponse(
    String appName,
    String userNickname,
    List<AiFriend> aiFriends,
    List<CreationCard> creationCards,
    ParentControl parentControl
) {
    public record ParentControl(
        int computeBudgetLimit,
        int dailyMinutesLimit,
        boolean allowPublicPublishing,
        boolean autoNarrationEnabled,
        boolean voiceInputEnabled
    ) {
    }
}
