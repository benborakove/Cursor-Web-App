package com.certificationmanager.data.converter

import androidx.room.TypeConverter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.Date

class Converters {
    @TypeConverter
    fun fromTimestamp(value: Long?): Date? {
        return value?.let { Date(it) }
    }

    @TypeConverter
    fun dateToTimestamp(date: Date?): Long? {
        return date?.time
    }

    @TypeConverter
    fun fromIntList(value: List<Int>?): String? {
        return value?.let { Gson().toJson(it) }
    }

    @TypeConverter
    fun toIntList(value: String?): List<Int>? {
        return value?.let {
            val listType = object : TypeToken<List<Int>>() {}.type
            Gson().fromJson(it, listType)
        }
    }
}